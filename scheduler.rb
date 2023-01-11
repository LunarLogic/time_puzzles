module Digest
  class Scheduler
    # Digest should be sent every Thursday at 18:30 UTC
    DIGEST_DAY = 4 # Thursday
    DIGEST_TIME = "18:30UTC"

    def should_run?(run_time)
      return true unless WeeklyDigest.exists?

      last_emit_time = WeeklyDigest.last.emitted_at
      last_scheduled_emit_time(run_time) > last_emit_time
    end

    def last_scheduled_emit_time(run_time)
      scheduled_emit_times
        .select { |emit_time| emit_time <= run_time }
        .last
    end

    private

    def scheduled_emit_times
      start_date = DateTime.parse("1/01/2023T#{DIGEST_TIME}")
      end_date = start_date + 5.years
      (start_date..end_date)
        .select { |date| date.wday == DIGEST_DAY }
        .sort
    end
  end
end
