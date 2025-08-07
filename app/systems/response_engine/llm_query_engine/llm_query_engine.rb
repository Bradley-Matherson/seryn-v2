# seryn/response_engine/llm_query_engine/llm_query_engine.rb

require_relative 'query_sanitizer'
require_relative 'prompt_constructor'
require_relative 'llm_router'
require_relative 'response_filter'
require_relative 'response_bridge'

module ResponseEngine
  module LLMQueryEngine
    module Controller
      class << self
        def generate_response(input:, intent:, context:)
          # Step 1 — Sanitize input for safety and tagging
          sanitized = QuerySanitizer.scrub_and_tag(input: input, context: context)
          tagged_input = sanitized[:input]
          flags = sanitized[:flags]

          # Step 2 — Construct full prompt for the LLM
          prompt = PromptConstructor.build(
            input: tagged_input,
            context: context,
            intent: intent
          )

          # Step 3 — Select model and query it
          raw_output = LLMRouter.query(prompt: prompt, context: context)

          # Step 4 — Filter raw LLM response for alignment and tone safety
          filtered = ResponseFilter.process(
            raw_output: raw_output,
            context: context
          )

          # Step 5 — Final formatting and logging
          ResponseBridge.finalize(
            content: filtered[:content],
            model: filtered[:model],
            tone: filtered[:tone],
            flags: filtered[:flags],
            trigger: intent
          )
        end
      end
    end
  end
end
