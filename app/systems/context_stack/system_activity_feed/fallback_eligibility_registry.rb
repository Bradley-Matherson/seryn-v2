# fallback_eligibility_registry.rb
# 🔁 FallbackEligibilityRegistry — defines and checks failover pathways between systems

module FallbackEligibilityRegistry
  FALLBACKS = {
    response_engine: [:llm_query_engine, :journal_echo_mode],
    strategy_engine: [:ledger_core, :guardian_autoplan],
    interpreter_system: [:direct_prompt_mode],
    external_llm: [:local_prompt_cache]
  }

  @engaged = {}

  def self.fallbacks_for(system)
    FALLBACKS[system] || []
  end

  def self.engage_fallback_for(system)
    fallback = fallbacks_for(system).first
    @engaged[system] = fallback
  end

  def self.engaged?(system)
    @engaged.key?(system)
  end

  def self.fallback_used(system)
    @engaged[system]
  end

  def self.any_fallback_engaged?
    @engaged.any?
  end

  def self.clear_all
    @engaged = {}
  end
end
