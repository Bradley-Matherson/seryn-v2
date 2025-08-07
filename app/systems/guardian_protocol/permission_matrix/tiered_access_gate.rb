# seryn/guardian_protocol/permission_matrix/tiered_access_gate.rb

module TieredAccessGate
  def self.validate(system:, tier:, trust_score:, context:)
    case tier
    when :blocked
      return deny("This system is completely locked without override.")
    when :restricted
      return trust_score >= 0.95 ? allow : deny("Restricted access — trust too low.")
    when :default
      return trust_score >= 0.65 ? allow : deny("Default access denied due to trust score.")
    when :earned
      return trust_score >= 0.82 ? allow : deny("Earned access denied — score too low.")
    when :trusted
      return allow
    else
      return deny("Unknown permission tier.")
    end
  end

  def self.allow
    {
      allowed: true,
      override_needed: false,
      reason: "Access granted."
    }
  end

  def self.deny(reason)
    {
      allowed: false,
      override_needed: true,
      reason: reason
    }
  end
end
