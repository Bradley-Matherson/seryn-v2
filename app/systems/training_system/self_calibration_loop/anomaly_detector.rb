# frozen_string_literal: true

# 🚨 AnomalyDetector
# Purpose:
# Identifies unexpected behavior in Seryn’s tone, task logic, or strategy routing.
# Flags inconsistencies, regression, or mismatches between user state and system output.

require_relative '../../guardian_protocol'
require_relative '../../strategy_engine'
require_relative '../../voice_trainer/tone_feedback_logger'

module TrainingSystem
  module SelfCalibrationLoop
    module AnomalyDetector
      def self.flag_irregularities(reflection, adjustments)
        flags = []

        if tone_misfired_while_user_was_drained?(reflection)
          flags << {
            type: :tone_misuse,
            context: "Drained state detected, but tone remained sharp.",
            severity: :moderate
          }
        end

        if repeated_trust_drop?(reflection)
          flags << {
            type: :trust_decline,
            context: "Multiple days of trust loss — trigger deeper review.",
            severity: :high
          }
        end

        if failed_strategy_recently?
          flags << {
            type: :strategy_fail,
            context: "Recent suggestion failed and was not adjusted.",
            severity: :moderate
          }
        end

        route_flags(flags)
        flags
      end

      def self.tone_misfired_while_user_was_drained?(reflection)
        last_tone = VoiceTrainer::ToneFeedbackLogger.load_log.last
        return false unless last_tone
        return false unless reflection[:emotional_trend] == :declining
        return last_tone[:tone_used].to_s.include?("command") || last_tone[:tone_used].to_s.include?("direct")
      end

      def self.repeated_trust_drop?(reflection)
        trust_log = GuardianProtocol.trust_log_last_days(3) rescue []
        drops = trust_log.count { |e| e[:delta] && e[:delta] < -0.01 }
        drops >= 2
      end

      def self.failed_strategy_recently?
        StrategyEngine.recent_failures&.any? rescue false
      end

      def self.route_flags(flags)
        flags.each do |flag|
          if flag[:severity] == :high || flag[:type] == :trust_decline
            GuardianProtocol::ViolationScanner.flag_violation(flag)
          end

          if flag[:type] == :strategy_fail
            StrategyEngine::FallbackGenerator.handle_failure(flag)
          end
        end
      end
    end
  end
end
