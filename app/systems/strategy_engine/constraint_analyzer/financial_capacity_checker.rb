# 📁 /seryn/strategy_engine/constraint_analyzer/financial_capacity_checker.rb

require_relative '../../../financial_core'
require_relative '../../../guardian_protocol'

module FinancialCapacityChecker
  SAFE_THRESHOLD = 75
  RISK_THRESHOLD = 30

  class << self
    def check
      funds = pull_available_funds
      frozen = spending_frozen?
      phase = evaluate_readiness_phase(funds, frozen)
      risk = warn_if_risky(funds, frozen)

      {
        cash_available: funds,
        spending_freeze: frozen,
        readiness_phase: phase,
        warning: risk,
        blocked: phase == :blocked
      }
    end

    def pull_available_funds
      FinancialCore.discretionary_funds.to_i rescue 0
    end

    def spending_frozen?
      FinancialCore.flags&.include?(:spending_lock)
    end

    def evaluate_readiness_phase(funds, frozen)
      return :blocked if frozen || funds < RISK_THRESHOLD
      return :risky if funds < SAFE_THRESHOLD
      :safe
    end

    def warn_if_risky(funds, frozen)
      if frozen
        "All spending is currently locked."
      elsif funds < RISK_THRESHOLD
        GuardianProtocol.alert(:finance_risk, "Funds too low for safe strategy execution (#{funds})")
        "Available funds are critically low."
      elsif funds < SAFE_THRESHOLD
        "Funds are low; avoid high-risk strategies."
      end
    end
  end
end
