# seryn/guardian_protocol/emergency_intervention_system/intervention_response_planner.rb

module InterventionResponsePlanner
  SEVERITY_MAP = {
    low: {
      mode: :nudge_reflection,
      lockdown_required: false,
      actions: [:prompt_journaling],
      cooldown_duration: 6 * 3600 # 6h
    },
    moderate: {
      mode: :task_lockout,
      lockdown_required: false,
      actions: [:lock_task_execution, :switch_to_therapeutic_mode],
      cooldown_duration: 24 * 3600 # 24h
    },
    high: {
      mode: :system_lockdown,
      lockdown_required: true,
      actions: [:restrict_strategy_engine, :disable_financial_modules],
      cooldown_duration: 48 * 3600 # 48h
    },
    critical: {
      mode: :full_lockdown,
      lockdown_required: true,
      actions: [:disable_self_edit, :enter_voice_journaling_mode, :freeze_router],
      cooldown_duration: 72 * 3600 # 72h
    }
  }

  def self.plan(trigger)
    severity = trigger[:severity]
    plan = SEVERITY_MAP[severity] || SEVERITY_MAP[:moderate]

    {
      mode: plan[:mode],
      lockdown_required: plan[:lockdown_required],
      actions: plan[:actions],
      cooldown_duration: plan[:cooldown_duration],
      override_allowed: trigger[:override_allowed]
    }
  end
end
