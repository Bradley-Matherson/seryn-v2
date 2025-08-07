# intent_confidence_scorer.rb
# 🧠 Scores clarity, emotional stability, and context alignment to produce a confidence float

module InterpreterSystem
  class IntentConfidenceScorer
    def self.score(input, category, context)
      score = 0.0

      # 1. Clarity check — short, vague input = low score
      score += clarity_boost(input)

      # 2. Category strength — if classified into something specific
      score += category.include?("unclassified") ? -0.2 : 0.2

      # 3. Context match bonus — match active goal or emotional state
      score += context_match_boost(input, context)

      # 4. Emotional content — unclear but emotional often = lower score
      score += emotional_penalty(input)

      # Clamp to 0.0–1.0 range
      [[score, 0.0].max, 1.0].min
    end

    def self.clarity_boost(input)
      words = input.strip.split.size
      return -0.2 if words < 3
      return 0.2 if words > 8
      0.1
    end

    def self.context_match_boost(input, context)
      input_down = input.downcase
      match = 0

      match += 0.1 if context[:active_goal] && input_down.include?(context[:active_goal].downcase)
      match += 0.1 if context[:ledger_task_focus] && input_down.include?(context[:ledger_task_focus].downcase)
      match
    end

    def self.emotional_penalty(input)
      lower = input.downcase
      if lower.include?("lost") || lower.include?("hopeless") || lower.include?("help")
        -0.15
      else
        0.0
      end
    end
  end
end
