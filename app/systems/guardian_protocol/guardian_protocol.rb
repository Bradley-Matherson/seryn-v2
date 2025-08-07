# core/guardian_protocol.rb

# 🛡️ GuardianProtocol — System Controller
# Top-level interface for all modules in the Guardian system

require_relative 'guardian/violation_scanner'
require_relative 'guardian/permission_matrix'
require_relative 'guardian/trust_score_engine'
require_relative 'guardian/behavior_watch'
require_relative 'guardian/emergency_override'
require_relative 'guardian/intervention_messenger'
require_relative 'guardian/audit_logger'

module GuardianProtocol
  def self.run_safety_checks(context)
    violations = ViolationScanner.scan(context)
    behavior_flags = BehaviorWatch.monitor(context)
    emergency = EmergencyOverride.check(context)

    all_flags = [*violations, behavior_flags].compact
    all_flags.each do |flag|
      InterventionMessenger.notify_user(flag)
    end

    emergency || all_flags.any? { |f| f[:severity] == :critical }
  end

  def self.trust_score(system)
    TrustScoreEngine.score(system)
  end

  def self.permission_granted?(action, system)
    score = trust_score(system)
    PermissionMatrix.allowed?(action, score)
  end

  def self.update_trust(system, delta)
    TrustScoreEngine.update(system, delta)
  end

  def self.log(flag)
    AuditLogger.log_violation(flag)
  end

  def self.health_status
    AuditLogger.health_check.merge(trust: TrustScoreEngine.all_scores)
  end
end
