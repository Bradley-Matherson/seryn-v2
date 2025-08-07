# seryn/guardian_protocol/emergency_intervention_system/emergency_intervention_system.rb

require_relative 'escalation_trigger_map'
require_relative 'intervention_response_planner'
require_relative 'lockdown_command_dispatcher'
require_relative 'override_cooldown_manager'
require_relative 'recovery_gatekeeper'

module EmergencyInterventionSystem
  def self.monitor(context)
    trigger = EscalationTriggerMap.detect(context)
    return unless trigger

    planned_response = InterventionResponsePlanner.plan(trigger)
    LockdownCommandDispatcher.dispatch(planned_response) if planned_response[:lockdown_required]

    OverrideCooldownManager.start_timer(trigger[:severity])
    log(trigger: trigger, response: planned_response)

    {
      emergency_triggered: true,
      level: trigger[:severity],
      cause: trigger[:pattern],
      actions: planned_response[:actions],
      cooldown_timer: planned_response[:cooldown_duration],
      review_required: true
    }
  end

  def self.recovery_check
    RecoveryGatekeeper.evaluate
  end

  def self.log(trigger:, response:)
    dir = "logs/guardian/emergency"
    FileUtils.mkdir_p(dir)
    timestamp = Time.now.strftime("%Y-%m-%d-%H%M%S")
    file = File.join(dir, "#{timestamp}.yml")

    File.write(file, {
      triggered_at: Time.now,
      trigger: trigger,
      response: response
    }.to_yaml)
  rescue => e
    puts "⚠️ Emergency log failed: #{e.message}"
  end
end
