# momentum_score_engine.rb
# 📊 MomentumScoreEngine — calculates current momentum score, trend, and burnout risk

module MomentumScoreEngine
  @score = 0.0
  @trend = :stable
  @burnout_warning = false
  @last_scores = []

  def self.compute(snapshot)
    # Weighted score logic
    score = 0.0
    score += snapshot[:tasks_completed] * 0.6
    score += snapshot[:reflections] * 0.4
    score += snapshot[:strategy_tasks_done] * 0.5
    score += snapshot[:engagement_hours] * 0.25
    score -= 2.0 if snapshot[:spiral]

    # Clamp to range
    @score = score.clamp(-5.0, 5.0).round(2)

    update_trend
    check_burnout
  end

  def self.update_trend
    @last_scores << @score
    @last_scores.shift while @last_scores.size > 7

    if @last_scores.size >= 3
      delta = @last_scores.last - @last_scores.first
      @trend =
        if delta > 1.0
          :rising
        elsif delta < -1.0
          :falling
        else
          :stable
        end
    end
  end

  def self.check_burnout
    low_days = @last_scores.count { |s| s < 1.5 }
    @burnout_warning = (low_days >= 3 && @score < 1.0)
  end

  def self.score
    @score
  end

  def self.trend
    @trend
  end

  def self.burnout?
    @burnout_warning
  end

  def self.snapshot
    {
      score: @score,
      trend: @trend,
      burnout_warning: @burnout_warning
    }
  end
end
