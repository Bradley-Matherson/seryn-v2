# 📁 core/strategy/tactical_planner/phase_generator.rb

module PhaseGenerator
  class << self
    def generate_phases(goal_hash, constraints)
      phases = build_phase_structure(goal_hash)
      phases.each_with_index.map do |phase, i|
        {
          name: phase[:name],
          tasks: phase[:tasks],
          est_effort: estimate_phase_effort(phase, constraints),
          fallback_ready: false,
          order: i + 1
        }
      end
    end

    def build_phase_structure(goal)
      case goal[:tags]
      when [:finance]
        [
          { name: "Audit & Log", tasks: ["Complete budget log", "Log credit score"] },
          { name: "Research & Setup", tasks: ["Research secured cards", "Choose credit builder tool"] },
          { name: "Execution", tasks: ["Activate account", "Begin 30-day activity cycle"] }
        ]
      when [:logistics]
        [
          { name: "Research & Price Check", tasks: ["Research truck options", "Set price ceiling"] },
          { name: "Save + Prep", tasks: ["Build savings buffer", "Prequalify or compare finance tools"] },
          { name: "Purchase & Transition", tasks: ["Buy truck", "Setup insurance + title"] }
        ]
      else
        [
          { name: "Plan Phase", tasks: ["Define milestone", "List required tools"] },
          { name: "Action Phase", tasks: ["Begin main tasks"] },
          { name: "Completion", tasks: ["Finalize + review"] }
        ]
      end
    end

    def estimate_phase_effort(phase, constraints)
      if constraints[:energy] == :low || constraints[:cash_available].to_i < 100
        :light
      elsif phase[:tasks].size > 4 || constraints[:competing_goals] > 2
        :medium
      else
        :high
      end
    end
  end
end
