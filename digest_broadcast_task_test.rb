require "test_helper"
require "rake"

class DigestBroadcastTaskTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    Emcap::Application.load_tasks if Rake::Task.tasks.empty?
  end

  test "run for the first time should schedule broadcast" do
    run_time = DateTime.parse("5/01/2023T18:31")
    travel_to run_time

    Rake::Task["digest:broadcast"].execute

    assert_enqueued_jobs 1
    wd = WeeklyDigest.last
    assert_equal wd.emitted_at, run_time
    assert_equal wd.scheduled_emit_time, DateTime.parse("5/01/2023T18:30")

    travel_back
  end

  test "run twice in a row should schedule broadcast only once" do
    run_time_1 = DateTime.parse("5/01/2023T18:31")
    travel_to run_time_1
    Rake::Task["digest:broadcast"].execute

    run_time_2 = DateTime.parse("5/01/2023T18:32")
    travel_to run_time_2
    Rake::Task["digest:broadcast"].execute

    assert_enqueued_jobs 1
    wd = WeeklyDigest.last
    assert_equal wd.emitted_at, run_time_1
    assert_equal wd.scheduled_emit_time, DateTime.parse("5/01/2023T18:30")

    travel_back
  end

  test "run and then run again next week should schedule broadcast twice" do
    run_time_1 = DateTime.parse("5/01/2023T18:31")
    travel_to run_time_1
    Rake::Task["digest:broadcast"].execute

    run_time_2 = DateTime.parse("12/01/2023T18:32")
    travel_to run_time_2
    Rake::Task["digest:broadcast"].execute

    assert_enqueued_jobs 2
    assert_equal WeeklyDigest.count, 2
    wd = WeeklyDigest.last
    assert_equal wd.emitted_at, run_time_2
    assert_equal wd.scheduled_emit_time, DateTime.parse("12/01/2023T18:30")

    travel_back
  end
end
