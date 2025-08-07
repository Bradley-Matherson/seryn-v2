# seryn/guardian_protocol/permission_matrix/permission_matrix.rb

require_relative 'permission_table'
require_relative 'trust_evaluator'
require_relative 'tiered_access_gate'
require_relative 'fluid_rule_resolver'
require_relative 'override_request_manager'

module PermissionMatrix
  def self.check(system:, context:)
    permission_entry = PermissionTable.get(system)
    trust_data = TrustEvaluator.evaluate(system: system, context: context)

    result = TieredAccessGate.validate(
      system: system,
      tier: permission_entry[:permission],
      trust_score: trust_data[:trust_score],
      context: context
    )

    # Apply fluid rules if needed
    if result[:allowed] == false
      fluid_result = FluidRuleResolver.resolve(system: system, context: context)
      result = fluid_result if fluid_result[:override_granted]
    end

    result.merge(
      system: system,
      tier: permission_entry[:permission],
      trust: trust_data[:trust_score],
      override_needed: result[:override_needed],
      triggered_by: context[:trigger] || :unknown
    )
  end

  def self.request_override(system:, reason:)
    OverrideRequestManager.initiate(system: system, reason: reason)
  end
end
