require "test_helper"

module Digest
  class SchedulerTest < ActiveSupport::TestCase
    setup do
      @sut = Digest::Scheduler.new
    end

    test "#call when first time" do
      assert @sut.should_run?(DateTime.parse("19/01/2023T18:30"))
    end

    test "#call" do
      WeeklyDigest.create(
        scheduled_emit_time: DateTime.parse("5/01/2023T18:30"),
        emitted_at: DateTime.parse("5/01/2023T18:31")
      )
      WeeklyDigest.create(
        scheduled_emit_time: DateTime.parse("12/01/2023T18:30"),
        emitted_at: DateTime.parse("12/01/2023T18:30")
      )

      refute @sut.should_run?(DateTime.parse("5/01/2023T18:30"))
      refute @sut.should_run?(DateTime.parse("12/01/2023T18:29"))
      refute @sut.should_run?(DateTime.parse("12/01/2023T18:30"))
      refute @sut.should_run?(DateTime.parse("12/01/2023T18:31"))
      refute @sut.should_run?(DateTime.parse("13/01/2023T18:31"))
      refute @sut.should_run?(DateTime.parse("19/01/2023T18:29"))

      assert @sut.should_run?(DateTime.parse("19/01/2023T18:30"))
      assert @sut.should_run?(DateTime.parse("19/01/2023T18:31"))
    end

    test "#last_scheduled_emit_time" do
      emit_time_1 = DateTime.parse("5/01/2023T18:30")
      emit_time_2 = DateTime.parse("12/01/2023T18:30")

      run_time = DateTime.parse("4/01/2023T18:30")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_nil last_scheduled_emit_time

      run_time = DateTime.parse("5/01/2023T18:30")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_1

      run_time = DateTime.parse("5/01/2023T18:31")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_1

      run_time = DateTime.parse("6/01/2023T18:30")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_1

      run_time = DateTime.parse("12/01/2023T18:29")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_1

      run_time = DateTime.parse("12/01/2023T18:30")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_2

      run_time = DateTime.parse("12/01/2023T18:31")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_2

      run_time = DateTime.parse("12/01/2023T19:30")
      last_scheduled_emit_time = @sut.last_scheduled_emit_time(run_time)
      assert_equal last_scheduled_emit_time, emit_time_2
    end
  end
end
