# 📁 /seryn/strategy_engine/constraint_analyzer/momentum_stability_gauge.rb

require_relative '../../../training_system'
require_relative '../../../context_stack'
require_relative '../../../guardian_protocol'

module MomentumStabilityGauge
  class << self
    def measure
      energy     = ContextStack[:energy] || :unknown
      mood       = ContextStack[:mood] || :neutral
      resistance = ContextStack[:resistance_flags] || []
      momentum   = TrainingSystem.momentum_7_day_score || 0.0

      burnout = burnout_risk?(energy, momentum)
      unstable = instability_detected?(energy, mood, resistance, burnout)

      trust_state = case
      when burnout then :unstable
      when unstable then :fragile
      else :stable
      end

      GuardianProtocol.alert(:momentum_instability, "Burnout or resistance flagged") if trust_state == :unstable

      {
        energy: energy,
        mood: mood,
        momentum_score: momentum.round(2),
        burnout_risk: burnout,
        trust_state: trust_state,
        warning: unstable ? "Emotional readiness is fragile" : nil,
        blocked: trust_state == :unstable
      }
    end

    def burnout_risk?(energy, momentum)
      low_energy = [:low, :very_low].include?(energy)
      momentum < 0.4 && low_energy
    end

    def instability_detected?(energy, mood, resistance_flags, burnout)
      return true if burnout
      return true if resistance_flags.any?
      return true if [:anxious, :drained, :distracted].include?(mood)
      false
    end
  end
end
