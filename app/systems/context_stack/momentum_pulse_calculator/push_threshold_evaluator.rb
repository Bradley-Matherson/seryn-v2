# push_threshold_evaluator.rb
# ⚖️ PushThresholdEvaluator — determines readiness to push, reflect, or recover

module PushThresholdEvaluator
  @push_clearance = false
  @action = :hold

  def self.evaluate(momentum_score, emotion)
    case
    when momentum_score >= 4.0 && [:focused, :hopeful, :sharp].include?(emotion)
      @action = :push
      @push_clearance = true

    when momentum_score < 1.0 && [:drained, :stuck, :empty].include?(emotion)
      @action = :reflect
      @push_clearance = false

    when momentum_score < 0.0 || [:spiraling, :chaotic].include?(emotion)
      @action = :protect
      @push_clearance = false

    else
      @action = :hold
      @push_clearance = false
    end
  end

  def self.push?
    @push_clearance
  end

  def self.recommendation
    @action
  end
end
