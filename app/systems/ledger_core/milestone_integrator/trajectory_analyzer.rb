# 📘 TrajectoryAnalyzer — Monitors Progress and Estimates Milestone Momentum
# Subcomponent of LedgerCore::MilestoneIntegrator

require_relative '../../../training_system/training_system'
require_relative '../../../strategy_engine/strategy_tracker'
require_relative '../../../interpreter_system/context_stack'

module LedgerCore
  module MilestoneIntegrator
    module TrajectoryAnalyzer
      class << self
        def evaluate(milestones)
          milestones.map do |m|
            m[:trajectory] = analyze_trajectory(m)
            m[:blocked]    = check_block_status(m)
            m[:last_updated] = days_since_last_update(m)
            m[:last_progress_delta] = delta_since_last_check(m)
            m
          end
        end

        private

        def analyze_trajectory(milestone)
          streak   = TrainingSystem::Controller.momentum_streak
          burnout  = TrainingSystem::Controller.burnout_warning?
          spiral   = TrainingSystem::Controller.recent_spiral?
          override = StrategyEngine::StrategyTracker.override_state_for(milestone[:id])

          return :blocked if override == :paused || override == :blocked
          return :stalled if burnout || spiral || streak < 1

          progress = milestone[:progress].to_f
          return :improving if progress > 50
          return :on_track if progress > 10

          :slow_start
        end

        def check_block_status(milestone)
          milestone[:trajectory] == :blocked ||
          (milestone[:resume_condition] && !condition_met?(milestone[:resume_condition]))
        end

        def condition_met?(condition)
          case condition
          when "truck paid off"
            false # Placeholder logic — extend with FinancialCore
          else
            true
          end
        end

        def days_since_last_update(milestone)
          # Placeholder until real milestone logging is online
          rand(1..8)
        end

        def delta_since_last_check(milestone)
          # Placeholder — simulate slight change in progress
          rand(-5.0..+5.0).round(1)
        end
      end
    end
  end
end
