# 📁 core/loop_triggers.rb

module LoopTriggers
  @registered_loops = [
    {
      loop: :weekly_trust_audit,
      triggers: [:guardian_flags, :spiral_count],
      interval: 7 * 24 * 60 * 60, # 7 days in seconds
      next_due: Time.now + 6 * 24 * 60 * 60
    },
    {
      loop: :strategy_reroute_check,
      triggers: [:milestone_stalled],
      interval: 3 * 24 * 60 * 60,
      next_due: Time.now + 2 * 24 * 60 * 60
    },
    {
      loop: :emergency_override,
      triggers: [:spiral_detected],
      interval: nil,
      next_due: nil # Event-triggered only
    }
  ]

  class << self
    def handle(trigger)
      puts "[LoopTriggers] Handling trigger: #{trigger}"

      @registered_loops.each do |loop|
        if loop[:triggers].include?(trigger)
          if loop[:interval] && Time.now >= loop[:next_due]
            run_loop(loop[:loop])
            loop[:next_due] = Time.now + loop[:interval]
          elsif loop[:interval].nil?
            run_loop(loop[:loop])
          end
        end
      end
    end

    def run_loop(loop_id)
      puts "[LoopTriggers] → Triggered internal loop: #{loop_id}"

      case loop_id
      when :weekly_trust_audit
        GuardianProtocol.audit_trust_levels
      when :strategy_reroute_check
        # Placeholder: Call StrategyEngine to reassess stuck strategies
        puts "[LoopTriggers] Strategy reroute logic pending implementation."
      when :emergency_override
        # Placeholder: Trigger internal override protocol
        puts "[LoopTriggers] Emergency override engaged. Guardian notified."
      end
    end

    def active_loops
      @registered_loops.map do |loop|
        {
          loop: loop[:loop],
          next_due: loop[:next_due]
        }
      end
    end
  end
end
