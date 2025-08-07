# 📁 core/strategy/tactical_planner/constraint_extractor.rb

require_relative '../../../training_system'
require_relative '../../../ledger_core'
require_relative '../../../financial_core'
require_relative '../../../mission_core'

module ConstraintExtractor
  class << self
    def extract(goal_tags)
      {
        energy: pull_energy_status,
        time: pull_time_window,
        cash_available: pull_financial_data(goal_tags),
        competing_goals: detect_competition
      }
    end

    def pull_energy_status
      TrainingSystem.energy_status # returns :high, :medium, :low
    end

    def pull_time_window
      LedgerCore.available_hours_next_30_days # returns number of hours
    end

    def pull_financial_data(tags)
      if tags.include?(:finance) || tags.include?(:logistics)
        FinancialCore.discretionary_funds # available cash for non-essentials
      else
        nil
      end
    end

    def detect_competition
      MissionCore.active_goals.count
    end
  end
end
