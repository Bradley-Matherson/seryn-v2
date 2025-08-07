# 📘 CycleClock — Maintains Temporal Awareness of Days, Weeks, and Custom Phases
# Subcomponent of LedgerCore::RhythmRegulator

require 'date'
require_relative '../../../memory/memory_logger'
require_relative '../../task_memory_bank/controller'

module LedgerCore
  module RhythmRegulator
    module CycleClock
      class << self
        def current_cycle
          cycle = {
            date: Date.today.to_s,
            day_of_week: Date.today.strftime("%A"),
            week_of_month: week_of_month,
            month: Date.today.strftime("%B"),
            is_weekly_reflection_day: weekly_reflection_day?,
            is_monthly_checkin_day: monthly_checkin_day?,
            is_reset_window: reset_window?,
            is_travel_prep_week: travel_week_window?
          }

          log_cycle(cycle)
          cycle
        end

        def weekly_reflection_day?
          Date.today.wday == 6 # Saturday
        end

        def monthly_checkin_day?
          Date.today.day == 15
        end

        def week_of_month
          ((Date.today.day - 1) / 7) + 1
        end

        def reset_window?
          [1, 2].include?(Date.today.day)
        end

        def travel_week_window?
          today = Date.today
          today >= Date.parse("#{today.year}-#{today.month}-25") &&
            today <= Date.parse("#{today.year}-#{today.month}-31")
        end

        private

        def log_cycle(cycle)
          MemoryLogger.append(:cycle_log, cycle)
          LedgerCore::TaskMemoryBank::Controller.log_rhythm_cycle(cycle)
        end
      end
    end
  end
end
