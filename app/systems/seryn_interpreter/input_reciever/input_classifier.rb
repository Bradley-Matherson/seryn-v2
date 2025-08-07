# input_classifier.rb
# 🏷️ Classifies normalized input into structural types for downstream logic

module InterpreterSystem
  class InputClassifier
    TYPE_PATTERNS = {
      instruction:     [/^(do|run|start|activate|generate|track|log)\b/, /\bchecklist\b/, /\bcomplete\b/, /\btask\b/],
      journal_entry:   [/\bi feel\b/, /\bi am\b/, /\byesterday\b/, /\bemotion\b/, /\bdrained\b/],
      goal_statement:  [/\bi want\b/, /\bi need\b/, /\bmy goal\b/, /\bbuild\b/, /\bearn\b/],
      feedback:        [/\byou did\b/, /\bthis didn[’']?t\b/, /\bthat worked\b/, /\byou should\b/]
    }

    def self.classify(text)
      TYPE_PATTERNS.each do |type, patterns|
        return type if patterns.any? { |pattern| text.match?(pattern) }
      end

      :ambiguous
    end
  end
end
