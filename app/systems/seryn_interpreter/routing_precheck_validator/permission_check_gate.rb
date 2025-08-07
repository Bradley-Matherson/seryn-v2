# permission_check_gate.rb
# 🔒 Checks GuardianProtocol and system trust tables to validate routing permissions

module InterpreterSystem
  class PermissionCheckGate
    TRUST_MATRIX = {
      strategy_engine:    true,
      ledger_core:        true,
      mission_core:       true,
      alignment_memory:   true,
      interface_core:     true,
      guardian_protocol:  true
    }

    GUARDIAN_BLOCKS = {
      strategy_engine:    false,
      ledger_core:        false,
      mission_core:       false,
      alignment_memory:   false,
      interface_core:     false,
      guardian_protocol:  false
    }

    def self.allowed?(route_tag)
      trust_ok = TRUST_MATRIX[route_tag] != false
      guardian_ok = !GUARDIAN_BLOCKS[route_tag]
      trust_ok && guardian_ok
    end

    # For testing or injection later
    def self.set_guardian_block(route_tag, blocked)
      GUARDIAN_BLOCKS[route_tag] = blocked
    end

    def self.set_trust(route_tag, allowed)
      TRUST_MATRIX[route_tag] = allowed
    end
  end
end
