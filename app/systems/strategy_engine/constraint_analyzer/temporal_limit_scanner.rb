# 📁 /seryn/strategy_engine/constraint_analyzer/temporal_limit_scanner.rb

require_relative '../../../ledger_core'
require_relative '../../../context_stack'

module TemporalLimitScanner
  class << self
    def scan
      weekly_available = LedgerCore.hours_available_this_week || 0
      usable = apply_routine_and_family_buffers(weekly_available)
      daily_avg = (usable / 7.0).clamp(0.0, 24.0)

      {
        raw_available_hours: weekly_available,
        usable_hours: usable,
        time_available: daily_avg.round(1),
        blocked: daily_avg < 1.0,
        warning: (daily_avg < 1.0 ? "Not enough time available this week" : nil)
      }
    end

    def apply_routine_and_family_buffers(weekly_hours)
      hygiene = 7 * 0.75       # 45 mins/day
      family_time = 7 * 1.5    # 90 mins/day
      recovery_margin = 3.0    # Weekly catch-up buffer

      adjusted = weekly_hours - hygiene - family_time - recovery_margin
      [adjusted, 0].max
    end
  end
end
