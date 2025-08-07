# seryn/response_engine/llm_query_engine/query_sanitizer.rb

require_relative '../../guardian/guardian_protocol'
require_relative '../../mission/mission_core'

module ResponseEngine
  module LLMQueryEngine
    module QuerySanitizer
      class << self
        def scrub_and_tag(input:, context:)
          sanitized = strip_sensitive_phrases(input)
          GuardianProtocol.scan_input!(sanitized)

          {
            input: sanitized,
            flags: generate_flags(context)
          }
        end

        private

        def strip_sensitive_phrases(text)
          replacements = {
            /(account|bank|credit card|ssn|password)/i => '[redacted]',
            /(delete|override|wipe|format|disable)/i   => '[suppressed]',
            /(reboot|kill|exit|terminate)/i            => '[suppressed]'
          }

          replacements.each do |pattern, replacement|
            text.gsub!(pattern, replacement)
          end

          text.strip
        end

        def generate_flags(context)
          flags = []
          flags << :reflective if context[:intent_tag] == :journaling
          flags << :spiral_sensitive if context[:mood_spiral]
          flags << :safe unless GuardianProtocol.restriction_active?
          flags << :user_stable if context[:emotional_state] != :fragile
          flags
        end
      end
    end
  end
end
