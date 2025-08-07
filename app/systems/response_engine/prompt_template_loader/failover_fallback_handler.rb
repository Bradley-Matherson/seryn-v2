# seryn/response_engine/prompt_template_loader/failover_fallback_handler.rb

require_relative '../../training/training_system'

module ResponseEngine
  module PromptTemplateLoader
    module FailoverFallbackHandler
      FALLBACK_RESPONSES = [
        "Let’s take a breath. Even without the perfect words, you’re still showing up — and that matters.",
        "I'm not sure I can answer that clearly, but I’m still here with you.",
        "When words fall short, presence still speaks. Let’s pause gently and come back stronger.",
        "Even if this prompt didn't load right, the reflection still matters. What do you feel in your chest right now?",
        "You don’t need the perfect prompt. Just a moment of honesty with yourself — and I’ll meet you there."
      ]

      class << self
        def handle_missing_template(intent:, context:)
          TrainingSystem.log_event(
            label: :template_missing,
            data: {
              intent: intent,
              identity: context[:identity_mode],
              emotional_state: context[:emotional_state],
              timestamp: Time.now
            }
          )

          build_fallback_response(tone: :gentle)
        end

        def handle_template_error(error:, context:)
          TrainingSystem.log_event(
            label: :template_render_error,
            data: {
              error_message: error.message,
              emotional_state: context[:emotional_state],
              trust_score: context[:trust_score],
              timestamp: Time.now
            }
          )

          build_fallback_response(tone: :gentle)
        end

        private

        def build_fallback_response(tone:)
          {
            source: :template,
            template_id: :fallback_prompt,
            variables: {},
            tone: tone,
            result: FALLBACK_RESPONSES.sample,
            format: :text
          }
        end
      end
    end
  end
end
