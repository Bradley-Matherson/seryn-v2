# seryn/response_engine/therapeutic_mirror_mode/language_mirror_engine.rb

module ResponseEngine
  module TherapeuticMirrorMode
    module LanguageMirrorEngine
      class << self
        def echo(input:, context:)
          key_phrase = extract_emotional_phrase(input)
          if key_phrase
            return build_reflection(key_phrase)
          end

          if contains_critical_self_talk?(input)
            return "That sounds heavy — what part of you believes that? What would your grounded self say in response?"
          end

          "Let’s pause here. What are you actually needing in this moment — beyond the noise?"
        end

        private

        def extract_emotional_phrase(text)
          match = text.match(/\b(i am|i’m|i feel|i've been)\s+(like\s+)?([a-z\s\-']{3,30})/i)
          match ? match[3].strip : nil
        end

        def build_reflection(phrase)
          "You said you feel ‘#{phrase}’ — where is that showing up today? What does that version of you need?"
        end

        def contains_critical_self_talk?(text)
          text.match?(/\b(i (always|never|suck|ruin|fail|can’t|mess(ed)? up|hate myself))\b/i)
        end
      end
    end
  end
end
