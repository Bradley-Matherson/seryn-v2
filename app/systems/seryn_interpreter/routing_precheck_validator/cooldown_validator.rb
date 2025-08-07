# cooldown_validator.rb
# 🕒 Prevents repeat-triggering of sensitive systems too quickly (rate limiter)

module InterpreterSystem
  class CooldownValidator
    COOLDOWN_INTERVALS = {
      strategy_engine:    300,  # 5 minutes
      guardian_protocol:  600,  # 10 minutes
      mission_core:       900   # 15 minutes
    }

    @@last_trigger_times = {}

    def self.check(route_tag)
      return nil unless COOLDOWN_INTERVALS.key?(route_tag)

      now = Time.now
      last = @@last_trigger_times[route_tag]
      cooldown = COOLDOWN_INTERVALS[route_tag]

      if last && (now - last < cooldown)
        remaining = cooldown - (now - last)
        format_duration(remaining)
      else
        @@last_trigger_times[route_tag] = now
        nil
      end
    end

    def self.format_duration(seconds)
      mins = (seconds / 60).floor
      secs = (seconds % 60).round
      format("%02d:%02d", mins, secs)
    end

    # Optional reset (e.g., after override)
    def self.reset(route_tag)
      @@last_trigger_times.delete(route_tag)
    end
  end
end
