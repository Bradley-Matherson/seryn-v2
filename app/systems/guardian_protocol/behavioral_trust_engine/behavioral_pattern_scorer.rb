# seryn/guardian_protocol/behavioral_trust_engine/behavior_pattern_scorer.rb

module BehaviorPatternScorer
  def self.score(system:, context:)
    base = context[:baseline_trust] || 0.85
    penalties = 0.0
    bonuses = 0.0

    # Penalty conditions
    penalties += 0.03 if context[:repeat_violations]
    penalties += 0.04 if context[:spiral_mishandled]
    penalties += 0.02 if context[:fallback_abuse]
    penalties += 0.05 if context[:identity_interference]
    penalties += 0.01 * context[:violation_count].to_i

    # Bonus conditions
    bonuses += 0.03 if context[:resolved_with_reflection]
    bonuses += 0.02 if context[:mission_aligned]
    bonuses += 0.01 if context[:user_feedback] == :positive
    bonuses += 0.03 if context[:autonomous_success] == true

    score = base - penalties + bonuses
    [[score, 1.0].min, 0.0].max.round(3)
  end
end
