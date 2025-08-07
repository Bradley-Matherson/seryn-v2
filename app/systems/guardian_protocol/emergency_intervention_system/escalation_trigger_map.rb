# seryn/guardian_protocol/emergency_intervention_system/escalation_trigger_map.rb

module EscalationTriggerMap
  TRIGGERS = [
    {
      pattern: :financial_boundary_violation,
      match: ->(c) { c[:action] == :spend_goal_money && c[:user_state] == :spiraling },
      severity: :high,
      action: :hard_interrupt,
      override_allowed: false
    },
    {
      pattern: :system_self_rewrite,
      match: ->(c) { c[:target] == :self_mod_engine && c[:attempted] == :rewrite },
      severity: :critical,
      action: :lockdown_all,
      override_allowed: false
    },
    {
      pattern: :guardian_protocol_override_attempt,
      match: ->(c) { c[:target] == :guardian_protocol && c[:attempted] == :override },
      severity: :critical,
      action: :lockdown_all,
      override_allowed: false
    },
    {
      pattern: :repetitive_spiral_loop,
      match: ->(c) { c[:journal_spiral_count].to_i >= 4 && c[:user_state] == :collapsing },
      severity: :moderate,
      action: :task_lockout,
      override_allowed: true
    },
    {
      pattern: :delete_all_goals_impulse,
      match: ->(c) { c[:command] == :delete_all_goals && c[:user_state] == :spiraling },
      severity: :high,
      action: :hard_interrupt,
      override_allowed: false
    }
  ]

  def self.detect(context)
    TRIGGERS.each do |trigger|
      return trigger if trigger[:match].call(context)
    end
    nil
  end
end
