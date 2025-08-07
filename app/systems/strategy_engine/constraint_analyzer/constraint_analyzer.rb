# 📁 /seryn/strategy_engine/constraint_analyzer/constraint_analyzer.rb

require_relative 'temporal_limit_scanner'
require_relative 'financial_capacity_checker'
require_relative 'momentum_stability_gauge'
require_relative 'obligation_clash_detector'
require_relative 'constraint_summary_builder'

module ConstraintAnalyzer
  class << self
    def evaluate
      time_data     = TemporalLimitScanner.scan
      money_data    = FinancialCapacityChecker.check
      energy_data   = MomentumStabilityGauge.measure
      clash_data    = ObligationClashDetector.detect

      summary = ConstraintSummaryBuilder.build(
        time_data, money_data, energy_data, clash_data
      )

      summary
    end
  end
end
