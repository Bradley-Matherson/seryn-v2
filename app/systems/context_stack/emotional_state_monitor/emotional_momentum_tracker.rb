# emotional_momentum_tracker.rb
# 📈 EmotionalMomentumTracker — tracks short-term trends in emotional trajectory

require 'time'

module EmotionalMomentumTracker
  HISTORY_LIMIT = 12
  @history = []  # Format: [{ emotion: :calm, timestamp: ..., confidence: 0.78 }]
  @momentum_score = 0.0
  @trend = :stable

  def self.update(vector)
    entry = {
      emotion: vector[:primary],
      confidence: vector[:confidence],
      timestamp: Time.now
    }

    @history << entry
    @history.shift while @history.size > HISTORY_LIMIT

    calculate_momentum
  end

  def self.calculate_momentum
    return if @history.size < 2

    # Translate emotion into numeric energy score
    scores = @history.map { |e| emotion_score(e[:emotion]) * e[:confidence] }
    diffs = scores.each_cons(2).map { |a, b| b - a }
    @momentum_score = diffs.sum.round(2)

    @trend =
      if @momentum_score > 0.25 then :improving
      elsif @momentum_score < -0.25 then :declining
      else :stable
      end
  end

  def self.emotion_score(emotion)
    case emotion
    when :focused then 1.0
    when :hopeful then 0.8
    when :calm then 0.6
    when :sharp then 0.6
    when :neutral then 0.5
    when :uncertain then 0.4
    when :drained then 0.3
    when :stuck then 0.2
    when :empty then 0.1
    when :spiraling, :chaotic then 0.0
    else 0.5
    end
  end

  def self.score
    @momentum_score
  end

  def self.trend
    @trend
  end
end
