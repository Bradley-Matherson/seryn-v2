# core/system_router/system_registry.rb

require_relative '../system_health_map'

module SystemRegistry
  class << self
    def lookup(system_key)
      registry = registered_systems

      return fallback_response(system_key) unless registry.key?(system_key)

      {
        available: registry[system_key][:available],
        trust_level: registry[system_key][:trust],
        health: SystemHealthMap.status_for(system_key)
      }
    end

    private

    def fallback_response(system_key)
      {
        available: false,
        trust_level: 0.0,
        health: :unknown
      }
    end

    def registered_systems
      {
        ledger_core: {
          available: true,
          trust: 0.85
        },
        strategy_engine: {
          available: true,
          trust: 0.92
        },
        guardian_protocol: {
          available: true,
          trust: 1.0
        },
        response_engine: {
          available: true,
          trust: 0.95
        },
        training_system: {
          available: true,
          trust: 0.87
        },
        mission_core: {
          available: true,
          trust: 0.93
        },
        identity_core: {
          available: true,
          trust: 0.89
        }
      }
    end
  end
end
