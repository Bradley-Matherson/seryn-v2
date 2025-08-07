# core/system_router/fallback_manager.rb

module FallbackManager
  class << self
    def resolve(system_key)
      fallback_map.fetch(system_key, :response_engine)
    end

    private

    def fallback_map
      {
        ledger_core: :response_engine,
        strategy_engine: :response_engine,
        mission_core: :guardian_protocol,
        training_system: :response_engine,
        identity_core: :ledger_core
      }
    end
  end
end
