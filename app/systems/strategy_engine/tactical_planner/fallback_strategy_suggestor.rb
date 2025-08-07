# 📁 core/strategy/tactical_planner/fallback_strategy_suggestor.rb

module FallbackStrategySuggestor
  class << self
    def suggest_for(phases, constraints)
      phases.map do |phase|
        risk = analyze_risk(phase, constraints)
        if risk
          phase[:fallback_ready] = true
          phase[:fallback_note] = fallback_for(phase[:name])
        end
        phase
      end
    end

    def analyze_risk(phase, constraints)
      return true if constraints[:energy] == :low && phase[:est_effort] == :high
      return true if constraints[:cash_available].to_i < 150 && phase[:name].downcase.include?("setup")
      return true if constraints[:competing_goals] > 3
      false
    end

    def fallback_for(phase_name)
      case phase_name.downcase
      when /audit/
        "Use last month's data or estimate manually."
      when /setup/
        "Delay paid tools. Use free alternatives."
      when /purchase/
        "Switch to used/discount option or delay."
      else
        "Cut scope in half and focus on core task only."
      end
    end
  end
end
