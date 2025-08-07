# routing_precheck_validator.rb
# 🧠 Final safety checkpoint before routing to SystemRouter

require_relative 'permission_check_gate'
require_relative 'active_context_conflict_detector'
require_relative 'cooldown_validator'
require_relative 'override_escalator'

module InterpreterSystem
  class RoutingPrecheckValidator
    def self.validate(route_tag:, intent:, context:)
      result = {
        approved: true,
        reason: nil,
        escalate: false,
        suggested_action: nil,
        cooldown_remaining: nil,
        override_available: false
      }

      # 1. Permission Check
      unless PermissionCheckGate.allowed?(route_tag)
        result[:approved] = false
        result[:reason] = "#{route_tag} blocked by GuardianProtocol or system restrictions"
        result[:escalate] = true
        result[:override_available] = true
        return result
      end

      # 2. Context Conflict Detection
      if conflict = ActiveContextConflictDetector.blocking_reason(route_tag, context)
        result[:approved] = false
        result[:reason] = conflict[:reason]
        result[:suggested_action] = conflict[:redirect]
        result[:escalate] = true
        result[:override_available] = true
        return result
      end

      # 3. Cooldown Validator
      if cooldown = CooldownValidator.check(route_tag)
        result[:approved] = false
        result[:reason] = "Cooldown active for #{route_tag}"
        result[:cooldown_remaining] = cooldown
        result[:suggested_action] = :wait_or_reflect
        return result
      end

      # 4. Override Escalator
      if OverrideEscalator.trigger?(intent, context)
        result[:approved] = false
        result[:reason] = "Intent conflicts with integrity or mission filter"
        result[:override_available] = true
        result[:escalate] = true
        result[:suggested_action] = :prompt_override
      end

      result
    end
  end
end
