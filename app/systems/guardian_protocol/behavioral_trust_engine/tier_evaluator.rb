# seryn/guardian_protocol/behavioral_trust_engine/tier_evaluator.rb

require_relative '../../../core/guardian/permission_matrix/permission_table'

module TierEvaluator
  LOCK_LIST = [:self_mod_engine]
  MIN_SELF_MOD_TRUST = 0.93
  FLAG_COOLDOWN_DAYS = 30

  def self.adjust_tier(system:, score:, context:)
    permission = PermissionTable.get(system)
    tier = permission[:permission]

    return 0.0 if tier == :blocked

    if LOCK_LIST.include?(system)
      recent_flag = context[:recent_flags]&.any? { |f| f[:system] == system && f[:timestamp] >= Time.now - (FLAG_COOLDOWN_DAYS * 86_400) }
      if score < MIN_SELF_MOD_TRUST || recent_flag
        PermissionTable::PERMISSIONS[system][:permission] = :blocked
        return -0.05
      end
    end

    # Optional future promotion/demotion logic here

    0.0
  end
end
