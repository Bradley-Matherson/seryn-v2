# frozen_string_literal: true

# 🧭 BehavioralAdjustmentPlanner
# Purpose:
# Translates daily reflection data into actionable behavioral modifications —
# including tone adjustments, prompt retries, pacing shifts, and identity reminders.

module TrainingSystem
  module SelfCalibrationLoop
    module BehavioralAdjustmentPlanner
      def self.plan_from(reflection)
        adjustments = []

        if reflection[:spiral_detected]
          adjustments << { action: :tone_shift, from: :reflective, to: :grounding }
          adjustments << { action: :pause_strategy_retry, reason: :emotional_instability }
        end

        if reflection[:trust_change] < -0.02
          adjustments << { action: :soften_prompt_style, reason: :trust_drop }
        elsif reflection[:trust_change] > 0.02
          adjustments << { action: :sharpen_prompt_style, reason: :trust_gain }
        end

        if reflection[:task_completion_rate].to_f < 0.5
          adjustments << { action: :slow_task_pacing, new_limit: 2 }
        elsif reflection[:task_completion_rate].to_f > 0.9
          adjustments << { action: :expand_task_complexity }
        end

        identity_gaps = detect_identity_imbalance(reflection[:identity_balance])
        if identity_gaps.any?
          adjustments << { action: :identity_nudge, underused_roles: identity_gaps }
        end

        {
          result: adjustments.empty? ? :no_adjustment : :minor_tweaks,
          actions: adjustments
        }
      end

      def self.detect_identity_imbalance(identity_balance)
        return [] unless identity_balance.is_a?(Hash)

        lowest_roles = identity_balance.sort_by { |_, v| v.to_i }.first(1)
        lowest_roles.map(&:first)
      end
    end
  end
end
