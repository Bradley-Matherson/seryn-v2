# momentum_pulse_calculator.rb
# 🔁 MomentumPulseCalculator — Master controller for drive, rhythm, and energy tracking

require_relative "rhythm_signal_collector"
require_relative "momentum_score_engine"
require_relative "push_threshold_evaluator"
require_relative "cycle_history_logger"
require_relative "recovery_window_forecaster"

module MomentumPulseCalculator
  def self.calculate_momentum
    RhythmSignalCollector.collect
    MomentumScoreEngine.compute(RhythmSignalCollector.snapshot)
    PushThresholdEvaluator.evaluate(
      MomentumScoreEngine.score,
      EmotionClassifier.primary
    )

    CycleHistoryLogger.log(MomentumScoreEngine.snapshot)
    RecoveryWindowForecaster.predict

    MomentumScoreEngine.score
  end

  def self.snapshot
    {
      score: MomentumScoreEngine.score,
      trend: MomentumScoreEngine.trend,
      burnout_warning: MomentumScoreEngine.burnout?,
      push_clearance: PushThresholdEvaluator.push?,
      projected_dip: RecoveryWindowForecaster.projected_dip
    }
  end
end
