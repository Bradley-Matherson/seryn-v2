# active_context_conflict_detector.rb
# ⚠️ Detects conflicts between identity, emotion, and mission constraints

module InterpreterSystem
  class ActiveContextConflictDetector
    def self.blocking_reason(route_tag, context)
      identity_mode = context[:identity_mode]       # e.g., :father, :builder
      emotional_state = context[:emotional_state]   # e.g., :burnout, :focused, :spiraling
      active_goal = context[:active_goal]           # e.g., :financial_peace, :homestead
      mission_block = context[:mission_boundary]    # e.g., :no_financial_risk

      # Block certain systems during spirals
      if emotional_state == :spiraling && route_tag == :strategy_engine
        return {
          reason: "Strategy actions are disabled during emotional spiral.",
          redirect: :journal_entry
        }
      end

      # Block financial goals during energy crashes
      if route_tag == :strategy_engine && emotional_state == :burnout && active_goal == :financial_independence
        return {
          reason: "Financial planning is paused during burnout.",
          redirect: :alignment_memory
        }
      end

      # Identity-role based mismatch (example: Builder trying to reflect)
      if identity_mode == :builder && route_tag == :alignment_memory
        return {
          reason: "Reflection mode not aligned with current Builder role.",
          redirect: :task_execution
        }
      end

      # MissionCore violation placeholder
      if mission_block == :no_goal_switch && route_tag == :mission_core
        return {
          reason: "MissionCore edits blocked by declared trajectory lock.",
          redirect: :guardian_protocol
        }
      end

      nil
    end
  end
end
