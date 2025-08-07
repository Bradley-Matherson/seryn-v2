# auto_inference_classifier.rb
# 🧭 Lightweight intent detector for routing and clarity scoring

module InterpreterSystem
  class AutoInferenceClassifier
    INTENT_PATTERNS = {
      strategy_request:      [/i want to/, /i need to/, /build.*income/, /fix.*spending/, /start saving/, /launch project/],
      emotional_reflection:  [/i feel/, /i am/, /it’s been hard/, /i’m overwhelmed/, /emotionally/, /spiraling/, /exhausted/],
      task_edit:             [/checklist/, /update task/, /move this/, /adjust goal/, /reschedule/, /remove from list/],
      new_goal:              [/new goal/, /change goal/, /replace my focus/, /set intention/],
      system_command:        [/run/, /start/, /activate/, /trigger/, /protocol/, /reset/, /turn on/]
    }

    def self.guess(text, context = {})
      text = text.downcase
      matches = {}

      INTENT_PATTERNS.each do |intent, patterns|
        match_count = patterns.count { |pattern| text.match?(pattern) }
        matches[intent] = match_count if match_count > 0
      end

      best = matches.max_by { |_, v| v }
      best ? best[0] : :ambiguous
    end
  end
end
