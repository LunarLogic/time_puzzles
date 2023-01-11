desc "Schedule weekly digest broadcast"
namespace :digest do
  task broadcast: :environment do
    # 1. Heroku scheduler runs this task at half past every hour (eg. 7:30, 8:30 etc)
    # 2. Digest should be broadcasted every Thursday at 6:30 PM UCT
    run_time = Time.zone.now
    scheduler = Digest::Scheduler.new

    if scheduler.should_run?(run_time)
      scheduled_emit_time = scheduler.last_scheduled_emit_time(run_time)

      DigestBroadcastJob.perform_later(emit_time: scheduled_emit_time)

      WeeklyDigest.create(
        scheduled_emit_time: scheduled_emit_time,
        emitted_at: run_time
      )
    end
  end
end

