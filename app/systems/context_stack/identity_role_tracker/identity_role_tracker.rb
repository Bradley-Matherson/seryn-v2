# identity_role_tracker.rb
# 🧠 Subsystem Controller — IdentityRoleTracker

require_relative "role_activation_log"
require_relative "mode_duration_timer"
require_relative "role_confidence_scorer"
require_relative "dominant_role_forecaster"
require_relative "role_history_store"

module IdentityRoleTracker
  def self.current_role
    RoleConfidenceScorer.analyze
    role = RoleConfidenceScorer.active_role
    confidence = RoleConfidenceScorer.confidence
    RoleActivationLog.log_if_changed(role)
    RoleHistoryStore.store(role, confidence)
    DominantRoleForecaster.forecast(role)
    [role, confidence]
  end

  def self.snapshot
    {
      active_role: RoleConfidenceScorer.active_role,
      confidence: RoleConfidenceScorer.confidence.round(2),
      mode_duration: ModeDurationTimer.duration_string,
      suggested_next: DominantRoleForecaster.suggested_next
    }
  end

  def self.current_anchor
    case RoleConfidenceScorer.active_role
    when :father then :family
    when :builder then :growth
    when :strategist then :purpose
    when :survivor then :freedom
    else :purpose
    end
  end
end
