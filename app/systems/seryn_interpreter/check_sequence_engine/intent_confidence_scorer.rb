# intent_confidence_scorer.rb
# 🎯 Scores how confidently Seryn can understand what the user wants

module InterpreterSystem
  class IntentConfidenceScorer
    def self.score(text, inferred_intent, context)
      score = 0.0

      # 1. Input structure – clarity and word count
      score += structure_bonus(text)

      # 2. Intent specificity
      score += intent_bonus(inferred_intent)

      # 3. Contextual overlap
      score += context_match_bonus(text, context)

      # 4. Emotional volatility penalty (basic for now)
      score -= volatility_penalty(text)

      # Clamp to 0.0 – 1.0
      [[score, 0.0].max, 1.0].min
    end

    def self.structure_bonus(text)
      words = text.strip.split.size
      return -0.2 if words < 3
      return 0.2  if words > 8
      0.1
    end

    def self.intent_bonus(inferred)
      return 0.25 if inferred.to_s.match?(/strategy|goal|task/)
      return 0.1  if inferred.to_s.match?(/journal|reflection/)
      0.0
    end

    def self.context_match_bonus(text, context)
      bonus = 0.0
      lower = text.downcase
      if context[:active_goal] && lower.include?(context[:active_goal].downcase)
        bonus += 0.15
      end
      if context[:input_type] && lower.include?(context[:input_type].to_s.gsub('_', ' '))
        bonus += 0.1
      end
      bonus
    end

    def self.volatility_penalty(text)
      return 0.15 if text.downcase.match?(/(nothing matters|i give up|erase everything|hopeless)/)
      0.0
    end
  end
end
