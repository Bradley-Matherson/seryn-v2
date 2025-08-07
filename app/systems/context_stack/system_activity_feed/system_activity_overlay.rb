# system_activity_overlay.rb
# 🧠 SystemActivityOverlay — generates real-time system focus + overlay state

require_relative "system_state_tracker"

module SystemActivityOverlay
  @overlay = {}

  def self.update_overlay
    states = SystemStateTracker.all_states

    active = states.select { |_k, v| v == :active }.keys
    throttled = states.count { |_k, v| v == :throttled }
    restricted = states.count { |_k, v| [:paused, :restricted, :fallback].include?(v) }

    total = states.size.to_f
    load_balance = ((active.size - restricted - throttled) / total).clamp(0.0, 1.0).round(2)

    focus = detect_focus(active)

    @overlay = {
      active_systems: active,
      focus: focus,
      load_balance: load_balance
    }
  end

  def self.detect_focus(active_systems)
    priority_order = [:strategy_engine, :training_system, :ledger_core, :response_engine]
    priority_order.find { |sys| active_systems.include?(sys) } || :idle
  end

  def self.overlay
    @overlay
  end

  def self.focus
    @overlay[:focus] || :unknown
  end
end
