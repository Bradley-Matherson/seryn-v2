# auto_inference_classifier.rb
# 🧠 Lightweight classifier to guess intent and emotional urgency

module InterpreterSystem
  class AutoInferenceClassifier
    KEYWORD_MAP = {
      journal:      %w[journal reflect entry feelings],
      financial:    %w[budget debt income passive money invest],
      task:         %w[complete checklist done task goal],
      identity:     %w[who am purpose father man values],
      spiral:       %w[stuck hopeless overwhelmed],
      command:      %w[run activate open shutdown execute],
      review:       %w[review reflect assess checkpoint],
      emotion:      %w[anxious tired sad angry off],
      crisis:       %w[panic harm erase delete emergency help],
    }

    def self.guess(input)
      input_down = input.downcase

      # Match against keyword map
      match_counts = KEYWORD_MAP.transform_values do |keywords|
        keywords.count { |kw| input_down.include?(kw) }
      end

      # Sort by most matches
      best_guess = match_counts.max_by { |_, v| v }

      # Return top match if it has at least 1 hit
      best_guess && best_guess[1] > 0 ? best_guess[0].to_s : 'unknown'
    end
  end
end
