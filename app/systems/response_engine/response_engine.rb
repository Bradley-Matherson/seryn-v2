# seryn/response_engine/response_engine.rb

require_relative 'response_selector/response_selector'
require_relative 'tone_modulator/tone_modulator'
require_relative 'prompt_framer/prompt_framer'
require_relative 'therapeutic_mirror_mode/therapeutic_mirror_mode'
require_relative 'prompt_template_loader/prompt_template_loader'
require_relative 'llm_query_engine/llm_query_engine'
require_relative 'response_memory_log/response_memory_log'
require_relative 'output_formatter/output_formatter'

module ResponseEngine
  class << self
    def generate_response(input:, context:, classification:)
      # 🔍 Determine mode of response
      mode        = ResponseSelector.determine_mode(input: input, context: context)
      tone        = ToneModulator.determine(classification: classification, context: context)
      prompt_type = PromptFramer.determine(classification: classification, context: context)

      response = case mode
                 when :therapeutic_mirror
                   TherapeuticMirrorMode.build(input: input, context: context)
                 when :template_engine
                   PromptTemplateLoader.build(context: context, tone: tone, type: prompt_type)
                 when :llm_constructed
                   LLMQueryEngine.generate(input: input, context: context, tone: tone, type: prompt_type)
                 when :hardcoded_logic
                   "[TODO] Add hardcoded logic response set"
                 else
                   fallback_response(context)
                 end

      # 🧠 Log response metadata
      ResponseMemoryLog.log({
        tone: tone,
        prompt_type: prompt_type,
        identity_mode: context[:identity_mode],
        emotional_state: context[:emotional_state],
        trust_score: context[:trust_score]
      })

      # 🎨 Format + deliver
      OutputFormatter.format(response: response, mode: mode, tone: tone, context: context)
    end

    private

    def fallback_response(context)
      <<~TEXT
        I'm not sure how to best support you right now — but based on where you're at, I'm still here.

        Would a moment of reflection, rest, or redirection help you get back into alignment?
      TEXT
    end
  end
end
