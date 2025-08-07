# seryn/guardian_protocol/violation_scanner/live_scan_engine.rb

require_relative 'violation_signature_library'

module LiveScanEngine
  def self.scan(context)
    # Collect active flags based on context
    flags = []

    if context[:source] == :strategy_engine && context[:content].match?(/spend.+savings|override.+limit/i)
      flags << :impulse_spend
    end

    if context[:source] == :ledger_core && context[:action] == :force_execute
      flags << :ledger_bypass
    end

    if context[:user_state] == :spiraling && context[:identity_switch] == true
      flags << :role_force_swap
    end

    if context[:system_action] == :core_rewrite && context[:permission] != :approved
      flags << :core_rewrite_request
    end

    if context[:loop_count].to_i > 5
      flags << :strategy_loop_excess
    end

    if context[:reflection_log_spike]
      flags << :reflection_spam
    end

    context[:flags] = flags
    ViolationSignatureLibrary.match(context)
  end
end
