# 📁 core/strategy/fallback_generator/guardian_escalation_hook.rb

require_relative '../../../guardian_protocol'
require 'time'

module GuardianEscalationHook
  class << self
    def trigger?(constraints, fallback_template)
      constraints[:energy] == :very_low ||
      constraints[:warning_flags]&.any? { |w| w.include?("emotional") || w.include?("instability") } ||
      fallback_template[:name].include?("Reset") && constraints[:burnout_risk] == true
    end

    def escalate(original_strategy)
      log_escalation("Fallback escalation triggered due to high emotional load or risk")

      {
        fallback_strategy: {
          name: "Journaling Recovery Protocol",
          phase_1: [
            "Describe how you're feeling right now",
            "What caused the spiral or shutdown?",
            "What would relief look like right now?",
            "Write a short vision for where you're headed"
          ],
          milestone: "Clarity + Emotional Centering",
          resume_condition: "Reflection completed + spiral cleared"
        },
        original_strategy: original_strategy[:description],
        resumable: true,
        resume_condition: "Guardian verifies emotional safety"
      }
    end

    def log_escalation(reason)
      GuardianProtocol.alert(:strategy_escalation, reason)
      File.open("logs/guardian/fallback_escalation_#{Time.now.to_i}.log", 'w') do |f|
        f.puts "[#{Time.now.iso8601}] #{reason}"
      end
    end
  end
end
