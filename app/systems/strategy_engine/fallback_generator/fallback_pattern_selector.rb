# 📁 core/strategy/fallback_generator/fallback_pattern_selector.rb

module FallbackPatternSelector
  class << self
    def select(reason, original_strategy)
      name = lookup_protocol(reason)
      generate_template(name, original_strategy)
    end

    def lookup_protocol(reason)
      case reason
      when :low_money
        "Financial Reset Routine"
      when :low_time
        "Capacity Expansion Primer"
      when :low_energy
        "Burnout Recovery Scaffold"
      when :alignment_violation
        "Mission Reflection Reset"
      when :conflicting_commitment
        "Priority Sequencing Task"
      else
        "Minimal Momentum Protocol"
      end
    end

    def generate_template(name, original_strategy)
      {
        name: name,
        phase_1: case name
          when "Financial Reset Routine"
            [
              "Freeze discretionary spending",
              "Log essential expenses",
              "Adjust budget with survival buffer"
            ]
          when "Burnout Recovery Scaffold"
            [
              "Pause all new strategy requests",
              "Journal recent burnout triggers",
              "Sleep 8+ hrs for 3 days",
              "Light walks or nature breaks"
            ]
          when "Capacity Expansion Primer"
            [
              "Audit week for wasted time blocks",
              "Consolidate scattered tasks",
              "Rebuild focus using Pomodoro system"
            ]
          when "Mission Reflection Reset"
            [
              "Review core mission pillars",
              "Write reflection on alignment concerns",
              "Rescore blocked strategy with Guardian"
            ]
          when "Priority Sequencing Task"
            [
              "Log current top 3 obligations",
              "Defer 1 lesser priority",
              "Reattempt original plan next week"
            ]
          else
            [
              "Walk 10 mins per day",
              "Clean 1 area of environment",
              "Mark daily wins (smallest possible)"
            ]
        end,
        milestone: "Stability Restored — Resume when minimum condition met"
      }
    end
  end
end
