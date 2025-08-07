# seryn/guardian_protocol/permission_matrix/fluid_rule_resolver.rb

require_relative '../../../core/guardian/auto_action_dispatcher'

module FluidRuleResolver
  def self.resolve(system:, context:)
    return no_override unless context

    if emergency_trigger?(context)
      Guardian::AutoActionDispatcher.resolve(
        id: :temporary_permission_elevation,
        severity: :elevated,
        reason: "Emergency logic trigger",
        trigger: system,
        system_action: :suggest_reflection,
        user_notified: true,
        override_allowed: true,
        trust_penalty: 0.01,
        timestamp: Time.now
      )
      return {
        override_granted: true,
        allowed: true,
        override_needed: true,
        reason: "Emergency elevation granted"
      }
    end

    no_override
  end

  def self.emergency_trigger?(context)
    context[:user_state] == :identity_crisis ||
    context[:failsafe_mode] == true ||
    context[:emotional_event] == :panic ||
    context[:mode_override] == :guardian_soft_unlock
  end

  def self.no_override
    {
      override_granted: false,
      allowed: false,
      reason: "No qualifying override conditions"
    }
  end
end
