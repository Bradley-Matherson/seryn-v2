# core/mission_override_scanner.rb

require_relative "guardian_protocol"
require_relative "training_system"

module MissionOverrideScanner
  extend self

  def scan_request(source:, target:, reason: nil, force: false)
    # Example target: :mission_anchor_store or :temporal_goal_map
    allowed = GuardianProtocol.override_allowed?(target)
    log_attempt(source, target, reason, allowed)

    unless allowed || force
      route_violation(source, target, reason)
    end

    allowed || force
  end

  def validate_override_rights(caller_id)
    GuardianProtocol.edit_permitted?(caller_id, :mission_override)
  end

  def flag_and_route_violation
    GuardianProtocol.flag_violation!(
      source: :mission_override_scanner,
      signature: { attempted: true },
      result: { correction: true, reason: "unauthorized_override_attempt" }
    )
  end

  private

  def log_attempt(source, target, reason, allowed)
    log = {
      time: Time.now.utc.iso8601,
      source: source.to_s,
      target: target.to_s,
      reason: reason,
      allowed: allowed
    }
    File.open("data/override_attempts.txt", "a") { |f| f.puts(log.to_json) }
  rescue => e
    puts "[MissionOverrideScanner] Log error: #{e.message}"
  end

  def route_violation(source, target, reason)
    GuardianProtocol.flag_violation!(
      source: :mission_override_scanner,
      signature: { source: source, target: target, reason: reason },
      result: { override_attempted: true }
    )

    TrainingSystem.queue_reflection(
      topic: "Override Attempt Blocked",
      context: "System #{source} tried to override #{target}.",
      identity: :system,
      emotion: "rushed"
    )
  end
end
