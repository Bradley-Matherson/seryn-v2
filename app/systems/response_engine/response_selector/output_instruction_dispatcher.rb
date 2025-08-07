# seryn/response_engine/response_selector/output_instruction_dispatcher.rb

require_relative '../../prompt/prompt_template_loader'
require_relative '../../llm/llm_query_engine'
require_relative '../../therapeutic/therapeutic_mirror_mode'
require_relative '../../output/output_formatter'

module ResponseEngine
  module ResponseSelector
    module OutputInstructionDispatcher
      class << self
        def dispatch(instruction:, input:, context:)
          mode         = instruction[:mode]
          prompt_type  = instruction[:prompt_type]
          tone         = instruction[:tone]
          identity     = instruction[:voice]
          delivery     = instruction[:delivery] || :text

          content = generate_content(
            mode: mode,
            input: input,
            context: context,
            prompt_type: prompt_type
          )

          formatted = OutputFormatter.format(
            content: content,
            tone: tone,
            identity: identity,
            confidence: context[:confidence] || 0.8,
            context: context,
            origin: mode
          )

          build_response_object(
            content: formatted,
            metadata: {
              type: instruction[:type],
              tone: tone,
              mode: mode,
              prompt_type: prompt_type,
              delivery: delivery,
              voice: identity,
              timestamp: Time.now
            }
          )
        end

        private

        def generate_content(mode:, input:, context:, prompt_type:)
          case mode
          when :template_engine
            PromptTemplateLoader::Controller.load_and_fill(intent: context[:intent_tag], context: context)[:result]
          when :llm_constructed
            LLMQueryEngine::Controller.generate_response(input: input, intent: context[:intent_tag], context: context)[:result]
          when :therapeutic_mirror
            TherapeuticMirrorMode::Controller.reflect(input: input, context: context)[:reflection]
          when :hardcoded_logic
            "[System Notice] No generation engine engaged. Static response required."
          else
            "[Fallback] I’m here, but I don’t have a clear way to respond to that yet."
          end
        end

        def build_response_object(content:, metadata:)
          {
            source: :response_engine,
            result: content,
            metadata: metadata,
            output_type: :structured_response,
            yaml_ready: true
          }
        end
      end
    end
  end
end
