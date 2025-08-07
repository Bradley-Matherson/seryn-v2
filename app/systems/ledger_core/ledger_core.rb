# 📘 LedgerCore — Life Execution + Task Integrity Engine
# Refactored to include enhanced subsystems for identity pacing, streak tracking, and feedback loops

require_relative 'task_flow_engine/controller'
require_relative 'reflection_loop_manager/controller'
require_relative 'streak_reinforcer/controller'
require_relative 'task_memory_bank/controller'
require_relative 'ledger_sync_relay/ledger_sync_relay'

module LedgerCore
  class << self
    def current_state
      task_output   = TaskFlowEngine::Controller.run
      reflection    = ReflectionLoopManager::Controller.analyze(task_output)
      streak_data   = StreakReinforcer::Controller.update(task_output, reflection)
      memory_output = TaskMemoryBank::Controller.store(task_output)

      state = {
        focus: task_output[:focus] || :none,
        tasks: task_output[:today_tasks],
        self_care: task_output[:self_care] || [],
        energy_level: task_output[:energy] || :unknown,
        momentum_level: task_output[:momentum_level] || "untracked",
        identity_mode: task_output[:identity_mode],
        reflections_due: reflection[:reflections_due],
        streaks: streak_data,
        memory_tags: memory_output[:patterns] || [],
        snapshot: generate_snapshot(task_output, streak_data, reflection)
      }

      sync_result = LedgerSyncRelay::Controller.sync_all(state)
      state.merge!(sync_result)

      state
    end

    private

    def generate_snapshot(task_output, streak_data, reflection)
      {
        date: Date.today.to_s,
        identity_mode: task_output[:identity_mode],
        tasks: task_output[:today_tasks],
        streak: streak_data[:journal_streak],
        focus: task_output[:focus],
        reflection_due: reflection[:reflections_due],
        load_scaled: task_output[:load_scaled]
      }
    end
  end
end
