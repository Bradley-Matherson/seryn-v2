# frozen_string_literal: true

# 🧠 TrainingSystem — Total System Controller
# Purpose:
# Master coordinator of all training subsystems.
# Oversees Seryn's evolution through emotional pattern mining, voice refinement,
# self-calibration, user behavior modeling, and feedback integration.

require_relative './training_system/memory_pattern_miner/memory_pattern_miner'
require_relative './training_system/voice_trainer/voice_trainer'
require_relative './training_system/self_calibration_loop/self_calibration_loop'
require_relative './training_system/user_behavior_profiler/user_behavior_profiler'
require_relative './training_system/action_feedback_loop'
require_relative './training_system/llm_shadow_training_tracker'

module TrainingSystem
  module Controller
    def self.run_training_cycle(cycle: :daily)
      case cycle
      when :daily
        run_daily_training
      when :weekly
        run_weekly_training
      else
        puts "[TrainingSystem] Unknown cycle: #{cycle}"
      end
    end

    def self.run_daily_training
      puts "[TrainingSystem] Running daily training sequence..."

      reflection = SelfCalibrationLoop.run_end_of_day_calibration
      update_behavior_profile
      log_shadow_training(reflection)

      puts "[TrainingSystem] Daily training complete."
      reflection
    end

    def self.run_weekly_training
      puts "[TrainingSystem] Running weekly pattern scan + behavior map..."

      MemoryPatternMiner.run_weekly_scan
      UserBehaviorProfiler.run_full_profile_update

      puts "[TrainingSystem] Weekly pattern mining complete."
    end

    def self.update_behavior_profile
      UserBehaviorProfiler.run_full_profile_update
    end

    def self.log_feedback(action_id:, result:, impact:, user_state:)
      ActionFeedbackLoop.log_action_result(
        action_id: action_id,
        result: result,
        impact: impact,
        user_state: user_state
      )
    end

    def self.log_shadow_training(prompt:, response:, type:, emotion:, success: true)
      LLMShadowTrainingTracker.store_interaction(
        prompt: prompt,
        response: response,
        type: type,
        emotion: emotion,
        success: success
      )
    end
  end
end
