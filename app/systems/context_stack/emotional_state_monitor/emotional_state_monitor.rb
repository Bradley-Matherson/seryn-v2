# emotional_state_monitor.rb
# 🔁 EmotionalStateMonitor — Subsystem controller for emotion sensing and risk evaluation

require_relative "emotion_classifier"
require_relative "emotional_momentum_tracker"
require_relative "spiral_risk_evaluator"
require_relative "mood_bias_logger"
require_relative "emotional_snapshot_store"

module EmotionalStateMonitor
  def self.read_emotion
    EmotionClassifier.analyze
    emotion = EmotionClassifier.primary
    risk = SpiralRiskEvaluator.evaluate(emotion)

    EmotionalMomentumTracker.update(EmotionClassifier.vector)
    MoodBiasLogger.log(emotion)
    EmotionalSnapshotStore.save_snapshot(
      emotion: emotion,
      secondary: EmotionClassifier.secondary,
      risk: risk,
      momentum: EmotionalMomentumTracker.score
    )

    [emotion, risk]
  end

  def self.reflection_window_open?
    EmotionClassifier.primary == :drained ||
    SpiralRiskEvaluator.level == :moderate ||
    MoodBiasLogger.skew_negative?
  end
end
