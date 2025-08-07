# seryn/guardian_protocol/behavioral_trust_engine/behavioral_trust_engine.rb

require_relative 'trust_ledger'
require_relative 'behavior_pattern_scorer'
require_relative 'tier_evaluator'
require_relative 'decay_monitor'
require_relative 'trust_pulse_broadcaster'

module BehavioralTrustEngine
  def self.update(system:, context:)
    pattern_score = BehaviorPatternScorer.score(system: system, context: context)
    delta = TierEvaluator.adjust_tier(system: system, score: pattern_score, context: context)
    DecayMonitor.apply(system: system, context: context)

    TrustLedger.log_entry(system: system, delta: delta, context: context)

    TrustPulseBroadcaster.send(system: system, score: pattern_score)
    {
      system: system,
      trust_score: pattern_score,
      delta: delta
    }
  end

  def self.trust_summary
    TrustLedger.current_scores
  end
end
