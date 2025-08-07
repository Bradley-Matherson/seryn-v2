# spiral_risk_evaluator.rb
# 🚨 SpiralRiskEvaluator — flags emotional danger zones and breakdown risks

require_relative "emotional_momentum_tracker"
require_relative "../../guardian_protocol/escalation_signal"
require_relative "../../training_system/journal_parser"

module SpiralRiskEvaluator
  LEVELS = [:none, :low, :moderate, :high, :critical]
  @level = :none
  @triggering_input = nil

  def self.evaluate(current_emotion)
    risk = :none
    reason_log = []

    # 1. Emotion type triggers
    if [:spiraling, :chaotic, :empty].include?(current_emotion)
      risk = :moderate
      reason_log << "emotion=#{current_emotion}"
    end

    # 2. Negative trend
    if EmotionalMomentumTracker.trend == :declining
      risk = escalate(risk, :low)
      reason_log << "declining trend"
    end

    # 3. GuardianProtocol signal
    if EscalationSignal.triggered?
      risk = escalate(risk, :high)
      reason_log << "guardian_protocol=flagged"
    end

    # 4. Overridden input flag
    latest_input = JournalParser.latest_entry_text
    if latest_input&.match?(/(delete everything|start over|i give up|i quit)/i)
      risk = escalate(risk, :critical)
      @triggering_input = latest_input
      reason_log << "override_phrase=#{latest_input.strip}"
    end

    @level = risk
    @level
  end

  def self.escalate(current, incoming)
    [LEVELS.index(current), LEVELS.index(incoming)].max.then { |i| LEVELS[i] }
  end

  def self.level
    @level
  end

  def self.triggering_input
    @triggering_input
  end
end
