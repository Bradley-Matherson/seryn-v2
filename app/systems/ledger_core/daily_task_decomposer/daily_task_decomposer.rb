# 📘 DailyTaskDecomposer — Subsystem Controller
# Subsystem of LedgerCore
# Refactored to include momentum-aware scaling, role pacing, and strategy phasing

require_relative 'strategy_phase_mapper'
require_relative 'momentum_scaler'
require_relative 'task_conflict_avoider'
require_relative 'micro_task_synthesizer'
require_relative 'ledger_task_assembler'
require_relative '../../../training_system/training_system'
require_relative '../../../mission_core/mission_core'
require_relative '../../../interpreter_system/context_stack'
require_relative '../../../strategy_engine/strategy_engine'

module LedgerCore
  module DailyTaskDecomposer
    class Controller
      class << self
        def run
          return fallback_output unless strategy_ready?

          identity_mode = ContextStack[:identity_mode] || MissionCore::Controller.current_role
          strategy_phase = StrategyPhaseMapper.extract_current_phase
          scaled_tasks   = MomentumScaler.scale(strategy_phase, identity_mode)
          cleaned_tasks  = TaskConflictAvoider.clean(scaled_tasks)
          micro_tasks    = MicroTaskSynthesizer.expand(cleaned_tasks)
          final_output   = LedgerTaskAssembler.assemble(micro_tasks)

          final_output.merge({
            identity_mode: identity_mode,
            load_scaled: true
          })
        end

        private

        def strategy_ready?
          active = StrategyEngine::StrategyTracker.current_phase
          return false if active.nil? || active[:status] == :pending
          true
        end

        def fallback_output
          {
            focus: :recovery_mode,
            today_tasks: ["Self-care prompt", "15 min journaling"],
            self_care: ["walk", "shower", "journal"],
            energy: :low,
            momentum_level: "paused",
            identity_mode: :recovery,
            load_scaled: false
          }
        end
      end
    end
  end
end
