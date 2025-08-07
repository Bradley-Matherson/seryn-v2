# seryn/response_engine/therapeutic_mirror_mode/reflective_prompt_library.rb

module ResponseEngine
  module TherapeuticMirrorMode
    module ReflectivePromptLibrary
      PROMPTS = {
        general: [
          "What would your grounded self say to you right now?",
          "What’s pulling you away from your purpose today?",
          "Is the voice in your head today kind or critical?",
          "What’s one truth you can hold onto in this moment?",
          "If you could speak to yourself with kindness, what would you say?"
        ],
        drained: [
          "What are you carrying that isn’t yours?",
          "Where in your body are you feeling that heaviness?",
          "What part of you needs the most care right now?"
        ],
        numb: [
          "If you could feel anything again, what would you want it to be?",
          "What brought you joy once that feels distant now?",
          "What emotion feels the most unreachable today?"
        ],
        guilt: [
          "What are you judging yourself for — and is that fair?",
          "Are you punishing yourself for something already forgiven?",
          "What would you say to a loved one in your shoes?"
        ],
        burnout: [
          "What’s the smallest step forward that doesn’t feel like pressure?",
          "What does true rest look like right now?",
          "Is this exhaustion from doing too much, or not enough of what matters?"
        ]
      }

      class << self
        def fetch(context:)
          emotion = context[:emotional_state].to_sym rescue :general
          PROMPTS[emotion] || PROMPTS[:general]
        end

        def fetch_random(context:)
          fetch(context: context).sample
        end
      end
    end
  end
end
