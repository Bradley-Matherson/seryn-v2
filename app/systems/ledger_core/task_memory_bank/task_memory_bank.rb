# 📘 TaskMemoryBank::Controller — Logs & Accesses Long-Term Task Patterns
# Subsystem of LedgerCore
# Purpose: Tracks trends like task decay, milestone links, streak logs, and reflection triggers.

require_relative 'task_decay_logger'
require_relative 'role_usage_logger'
require_relative 'milestone_linker'
require_relative 'reflection_log'
require_relative 'momentum_tracker'

module LedgerCore
  module TaskMemoryBank
    class Controller
      class << self
        # 🔁 Logs that a task has been deferred multiple times
        def log_decay_event(task)
          TaskDecayLogger.record(task)
        end

        # 👤 Logs identity role neglect or gaps
        def log_role_neglect(role:, days_inactive:, timestamp:)
          RoleUsageLogger.record(role: role, days: days_inactive, time: timestamp)
        end

        # 🧩 Logs link between task and milestone
        def log_milestone_activity(tagged_tasks)
          MilestoneLinker.record(tagged_tasks)
        end

        # 🪞 Logs reflection prompts and context
        def log_reflection_trigger(message:, category:, triggered_at:)
          ReflectionLog.record(message: message, category: category, time: triggered_at)
        end

        # 📈 Logs momentum streak and consistency data
        def log_momentum_trend(type:, value:, timestamp:)
          MomentumTracker.record(type: type, value: value, time: timestamp)
        end

        # 🕰️ Logs cycle context for rhythm memory
        def log_rhythm_cycle(cycle_hash)
          MomentumTracker.record_cycle(cycle_hash)
        end
      end
    end
  end
end
