# system_state_tracker.rb
# 📡 SystemStateTracker — tracks real-time status of major systems and error states

module SystemStateTracker
  SYSTEMS = [
    :interpreter_system,
    :strategy_engine,
    :guardian_protocol,
    :ledger_core,
    :response_engine,
    :training_system,
    :mission_core,
    :context_stack,
    :seryn_core,
    :external_llm
  ]

  VALID_STATES = [
    :active, :paused, :restricted, :throttled,
    :error, :rebuilding, :fallback
  ]

  @system_states = {}
  @last_error = nil

  def self.set(system, state)
    return unless SYSTEMS.include?(system)
    return unless VALID_STATES.include?(state)

    @system_states[system] = state
    @last_error = "#{system} → #{state}" if state == :error
  end

  def self.status(system)
    @system_states[system] || :unknown
  end

  def self.all_states
    SYSTEMS.map { |s| [s, status(s)] }.to_h
  end

  def self.active_count
    @system_states.count { |_k, v| v == :active }
  end

  def self.last_error
    @last_error
  end

  def self.reset_error_log
    @last_error = nil
  end
end
