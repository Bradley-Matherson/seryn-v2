# seryn/guardian_protocol/permission_matrix/trust_evaluator.rb

require_relative '../../../core/guardian/trust_score_engine'
require_relative '../../../core/guardian/violation_scanner'

module TrustEvaluator
  def self.evaluate(system:, context:)
    trust = Guardian::TrustScoreEngine.trust_score(system)

    recent_flags = context[:recent_flags] || []
    spiraling = context[:user_state] == :spiraling
    mission_violation = context[:mission_alignment_score].to_f < 0.5

    escalated_risk = recent_flags.any? { |f| f[:trigger] == system } || spiraling || mission_violation

    {
      trust_score: trust.round(3),
      escalated_risk: escalated_risk,
      permission_tier: resolve_tier(trust)
    }
  end

  def self.resolve_tier(trust)
    case trust
    when 0.0..0.60 then :restricted
    when 0.61..0.80 then :default
    when 0.81..0.94 then :earned
    else :trusted
    end
  end
end
