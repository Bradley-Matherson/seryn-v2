# 📘 ReflectionTriggerEngine — Injects Prompts Based on Rhythm, Emotion, or Cycles
# Subcomponent of LedgerCore::RhythmRegulator

require_relative '../../../training_system/training_system'
require_relative '../../../response_engine/response_engine'
require_relative '../../../ledger_core/rhythm_regulator/cycle_clock'
require_relative '../../task_memory_bank/controller'

module LedgerCore
  module RhythmRegulator
    module ReflectionTriggerEngine
      class << self
        def reflection_due?
          TrainingSystem::Controller.momentum_streak < 2 ||
            CycleClock.weekly_reflection_day? ||
            TrainingSystem::Controller.recent_spiral?
        end

        def inject_prompts_if_needed(rhythm_snapshot)
          return unless rhythm_snapshot[:reflections_due]

          prompts.each do |prompt|
            ResponseEngine::Controller.inject_reflection(prompt[:text])
            log_prompt_to_memory(prompt)
          end
        end

        private

        def prompts
          [
            { text: "How was this week emotionally?", category: :weekly },
            { text: "Where did you drift from your goal?", category: :momentum },
            { text: "What are you proud of?", category: :identity },
            { text: "What do you want to adjust next week?", category: :planning }
          ]
        end

        def log_prompt_to_memory(prompt)
          LedgerCore::TaskMemoryBank::Controller.log_reflection_trigger(
            message: prompt[:text],
            category: prompt[:category],
            triggered_at: Time.now.utc.iso8601
          )
        end
      end
    end
  end
end
