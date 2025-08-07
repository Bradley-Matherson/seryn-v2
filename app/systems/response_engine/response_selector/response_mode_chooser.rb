# seryn/response_engine/response_selector/response_mode_chooser.rb

require_relative '../../guardian/guardian_protocol'
require_relative 'prompt_framer'

module ResponseEngine
  module ResponseSelector
    module ResponseModeChooser
      class << self
        def choose(classification:, context:)
          trust = context[:trust_score] || 0.7
          spiral = classification[:tags]&.include?(:spiral_risk)
          guardian_soft = GuardianProtocol.enforce_soft_response?

          # If guardian forces therapeutic safety
          return :therapeutic_mirror if guardian_soft

          # Prompt function classification
          prompt_type = PromptFramer.frame_type(
            classification: classification,
            context: context,
            identity: context[:identity_mode]
          )

          case prompt_type
          when :mirror
            return :therapeutic_mirror
          when :reflection
            return trust >= 0.7 ? :template_engine : :llm_constructed
          when :challenge
            return trust >= 0.9 ? :template_engine : :llm_constructed
          when :strategic
            return context[:confidence] >= 0.8 ? :template_engine : :llm_constructed
          when :grounding
            return :template_engine
          else
            fallback_mode(context[:confidence])
          end
        end

        private

        def fallback_mode(confidence)
          return :llm_constructed if confidence < 0.6
          return :template_engine if confidence < 0.85
          :hardcoded_logic
        end
      end
    end
  end
end
