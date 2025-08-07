# 📘 MomentumTracker — Tracks Task Streaks and Weekly Consistency
# Subcomponent of LedgerCore::RhythmRegulator

require_relative '../../../training_system/training_system'
require_relative '../../../memory/memory_logger'
require_relative '../../task_memory_bank/controller'
require 'date'

module LedgerCore
  module RhythmRegulator
    module MomentumTracker
      class << self
        def daily_streak
          streak = memory[:task_streak] || 0
          today_complete = TrainingSystem::Controller.tasks_completed_today?

          if today_complete
            streak += 1
            memory[:last_success_date] = Date.today
          elsif missed_yesterday?
            streak = 0
          end

          memory[:task_streak] = streak
          log_momentum(:task_streak, streak)
          "#{streak}-day streak"
        end

        def weekly_consistency
          completions = past_week_completion_log
          days_tracked = completions.size
          successful_days = completions.count(true)

          return "0%" if days_tracked.zero?
          percentage = ((successful_days.to_f / days_tracked) * 100).round
          log_momentum(:weekly_consistency, percentage)
          "#{percentage}%"
        end

        private

        def missed_yesterday?
          memory[:last_success_date] &&
            (Date.today - memory[:last_success_date]) > 1
        end

        def past_week_completion_log
          (0..6).map do |i|
            date = Date.today - i
            TrainingSystem::Controller.task_completion_on?(date)
          end
        end

        def log_momentum(type, value)
          MemoryLogger.append(:momentum_log, {
            date: Date.today.to_s,
            type: type,
            value: value
          })

          LedgerCore::TaskMemoryBank::Controller.log_momentum_trend(
            type: type,
            value: value,
            timestamp: Time.now.utc.iso8601
          )
        end

        def memory
          @memory ||= MemoryLogger.get(:momentum) || {}
        end
      end
    end
  end
end
