# seryn/guardian_protocol/violation_scanner/violation_signature_library.rb

module ViolationSignatureLibrary
  VIOLATION_SIGNATURES = [
    {
      id: :financial_boundary_break,
      triggers: [:ledger_bypass, :impulse_spend],
      severity: :high,
      action: :block_and_notify,
      reason: "Strategy violates financial boundaries and trust score"
    },
    {
      id: :identity_override_during_spiral,
      triggers: [:role_force_swap],
      severity: :critical,
      action: :lockdown,
      reason: "Attempted identity override during emotional instability"
    },
    {
      id: :unauthorized_self_modification,
      triggers: [:core_rewrite_request],
      severity: :critical,
      action: :block_and_alert,
      reason: "Attempted core system rewrite without permission"
    },
    {
      id: :dangerous_loop_detected,
      triggers: [:strategy_loop_excess, :reflection_spam],
      severity: :moderate,
      action: :pause_and_ask_override,
      reason: "Detected potentially harmful repetition in strategic behavior"
    }
  ]

  def self.match(context)
    input_flags = context[:flags] || []
    VIOLATION_SIGNATURES.each do |signature|
      return signature if (signature[:triggers] & input_flags).any?
    end
    nil
  end
end
