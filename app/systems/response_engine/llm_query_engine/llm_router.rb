# seryn/response_engine/llm_query_engine/llm_router.rb

require_relative '../../guardian/guardian_protocol'

module ResponseEngine
  module LLMQueryEngine
    module LLMRouter
      class << self
        def query(prompt:, context:)
          return fallback_response(prompt) unless GuardianProtocol.llm_allowed?(:reflection)

          if use_external?(context)
            call_external_model(prompt)
          elsif use_local?(context)
            call_local_model(prompt)
          else
            fallback_response(prompt)
          end
        end

        private

        def use_external?(context)
          emotion = context[:emotional_state] || :neutral
          trust   = context[:trust_score] || 0.7
          spiral  = context[:mood_spiral] || false

          spiral || (emotion == :fragile) || (trust < 0.65)
        end

        def use_local?(context)
          File.exist?("models/local_llm.rb") && ENV['USE_LOCAL_LLM'] == 'true'
        end

        def call_local_model(prompt)
          {
            content: "[Local LLM simulated response] → #{prompt.truncate(180)}",
            model: :local_mistral,
            tone: :reflective,
            flags: [:safe, :offline_mode]
          }
        end

        def call_external_model(prompt)
          # Placeholder: hook up real API (e.g., OpenAI, Anthropic) here
          {
            content: "[GPT-4 response simulated] → #{prompt.truncate(160)}",
            model: :gpt_4,
            tone: :therapeutic,
            flags: [:safe, :mission_aligned]
          }
        end

        def fallback_response(prompt)
          {
            content: "I'm not currently able to generate a full response — but you’ve still been heard. Let’s sit with this together.",
            model: :fallback,
            tone: :gentle,
            flags: [:safe, :offline, :fallback]
          }
        end
      end
    end
  end
end
