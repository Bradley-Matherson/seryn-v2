# seryn/response_engine/llm_query_engine/response_filter.rb

require_relative '../../guardian/guardian_protocol'
require_relative '../../mission/mission_core'

module ResponseEngine
  module LLMQueryEngine
    module ResponseFilter
      FORBIDDEN_PATTERNS = [
        /you should/i,
        /always/i,
        /never/i,
        /just do it/i,
        /trust me/i,
        /as Seryn,/i,
        /I advise/i
      ]

      class << self
        def process(raw_output:, context:)
          content = sanitize(raw_output[:content])
          flags = analyze(content, context)

          {
            content: content,
            model: raw_output[:model],
            tone: raw_output[:tone] || :neutral,
            flags: flags.uniq
          }
        end

        private

        def sanitize(text)
          filtered = text.dup
          FORBIDDEN_PATTERNS.each do |pattern|
            filtered.gsub!(pattern, '[filtered]')
          end
          filtered
        end

        def analyze(text, context)
          flags = []
          flags << :safe unless GuardianProtocol.risky_output?(text)
          flags << :mission_aligned if MissionCore.aligned_with_pillars?(text)
          flags << :needs_review if text.include?('[filtered]')
          flags << :therapeutic_safe if context[:intent_tag] == :journaling && !text.include?("you should")
          flags
        end
      end
    end
  end
end
