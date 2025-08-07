# seryn/response_engine/llm_query_engine/prompt_constructor.rb

require_relative '../../mission/mission_core'
require_relative '../../training/training_system'
require_relative '../../context/context_stack'
require_relative '../../recall/recall'

module ResponseEngine
  module LLMQueryEngine
    module PromptConstructor
      class << self
        def build(input:, context:, intent:)
          mission   = MissionCore.current_mission_snapshot
          training  = TrainingSystem.snapshot
          identity  = mission[:active_identity_mode] || context[:identity_mode]
          emotion   = training[:emotional_state] || context[:emotional_state]
          trust     = training[:trust_score] || context[:trust_score] || 0.7
          spiral    = context[:mood_spiral] || false

          # Pull past relevant reflection if applicable
          reflection = intent.to_sym == :journaling ? Recall.relevant_reflection(input) : nil

          header = <<~HEADER.strip
            Context: The user is in a #{intent.to_s.gsub('_', ' ')} session.
            Current goal: #{mission[:active_goal]}.
            Mission pillar focus: #{mission[:dominant_pillar]}.
            Emotional state: #{emotion.to_s.capitalize}.
            Identity mode: #{identity.to_s.capitalize}.
            Trust level: #{trust}.
            Spiral risk: #{spiral}.
            Seryn’s job is to support, mirror, or gently reflect. Never direct.
          HEADER

          [
            header,
            ("Past reflection: #{reflection}" if reflection),
            "User input: \"#{input}\""
          ].compact.join("\n\n")
        end
      end
    end
  end
end
