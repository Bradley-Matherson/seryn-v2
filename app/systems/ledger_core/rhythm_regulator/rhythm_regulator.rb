# 📘 RhythmRegulator — Subsystem of LedgerCore
# Purpose: Maintain behavioral cadence, momentum, and identity rotation balance

require_relative 'momentum_tracker'
require_relative 'cycle_clock'
require_relative 'task_decay_watcher'
require_relative 'role_rotation_balancer'
require_relative 'reflection_trigger_engine'
require_relative '../task_memory_bank/controller'
require_relative '../../memory/memory_logger'

module LedgerCore
  module RhythmRegulator
    class Controller
      class << self
        def evaluate
          streak         = MomentumTracker.daily_streak
          consistency    = MomentumTracker.weekly_consistency
          neglected_role = RoleRotationBalancer.detect_neglect
          active_cycle   = CycleClock.current_cycle
          reflection_due = ReflectionTriggerEngine.reflection_due?

          rhythm = {
            daily_momentum: streak,
            weekly_consistency: consistency,
            neglected_role: neglected_role,
            active_cycle: active_cycle,
            reflections_due: reflection_due
          }

          TaskDecayWatcher.scan
          ReflectionTriggerEngine.inject_prompts_if_needed(rhythm)
          log_rhythm_state(rhythm)

          rhythm
        end

        private

        def log_rhythm_state(rhythm)
          MemoryLogger.append(:rhythm_snapshot, {
            date: Date.today.to_s,
            streak: rhythm[:daily_momentum],
            consistency: rhythm[:weekly_consistency],
            neglected_role: rhythm[:neglected_role],
            reflection_due: rhythm[:reflections_due]
          })

          LedgerCore::TaskMemoryBank::Controller.log_rhythm_pattern(rhythm)
        end
      end
    end
  end
end
