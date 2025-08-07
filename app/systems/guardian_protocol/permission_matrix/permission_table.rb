# seryn/guardian_protocol/permission_matrix/permission_table.rb

module PermissionTable
  PERMISSIONS = {
    strategy_engine: {
      permission: :earned,
      trust_threshold: 0.82,
      cooldown_on_violation: 2 * 86_400, # seconds
      override_allowed: true
    },
    ledger_core: {
      permission: :default,
      trust_threshold: 0.65,
      override_allowed: true
    },
    response_engine: {
      permission: :default,
      trust_threshold: 0.6,
      override_allowed: true
    },
    training_system: {
      permission: :earned,
      trust_threshold: 0.75,
      override_allowed: false
    },
    mission_core: {
      permission: :restricted,
      trust_threshold: 0.95,
      override_allowed: false
    },
    self_mod_engine: {
      permission: :blocked,
      trust_threshold: 1.0,
      override_allowed: false
    }
  }

  def self.get(system)
    PERMISSIONS[system] || {
      permission: :default,
      trust_threshold: 0.7,
      override_allowed: false
    }
  end
end
