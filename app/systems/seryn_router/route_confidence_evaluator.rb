# core/system_router/route_confidence_evaluator.rb

require_relative '../training_system'

module RouteConfidenceEvaluator
  class << self
    def score(interpreter_confidence, trust_level, category)
      history_score = TrainingSystem.category_success_rate(category)

      weights = {
        interpreter: 0.5,
        trust: 0.3,
        history: 0.2
      }

      (
        interpreter_confidence * weights[:interpreter] +
        trust_level * weights[:trust] +
        history_score * weights[:history]
      ).round(4)
    rescue => e
      puts "[RouteConfidenceEvaluator] Scoring error: #{e.message}"
      fallback_score
    end

    private

    def fallback_score
      0.5
    end
  end
end
