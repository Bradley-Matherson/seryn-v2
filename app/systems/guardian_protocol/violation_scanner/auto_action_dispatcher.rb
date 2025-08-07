# seryn/guardian_protocol/violation_scanner/auto_action_dispatcher.rb

require_relative '../../../core/guardian/intervention_messenger'
require_relative '../../../core/guardian/trust_score_engine'

module AutoActionDispatcher
  def self.resolve(violation)
    case violation[:system_action]
    when :block_and_notify
      Guardian::InterventionMessenger.notify_user(:hard, violation)
    when :pause_and_ask_override
      Guardian::InterventionMessenger.notify_user(:soft, violation)
    when :lockdown
      Guardian::InterventionMessenger.notify_user(:emergency, violation)
    when :block_and_alert
      Guardian::InterventionMessenger.notify_user(:hard, violation)
    when :suggest_reflection
      Guardian::InterventionMessenger.notify_user(:soft, violation)
    end

    apply_trust_penalty(violation[:trigger], violation[:trust_penalty])
  end

  def self.apply_trust_penalty(system, penalty)
    return unless system && penalty
    Guardian::TrustScoreEngine.update_trust(system, -penalty)
  end
end
