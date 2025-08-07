# seryn/response_engine/prompt_framer/prompt_framer.rb

require_relative '../../mission/mission_core'
require_relative '../../training/training_system'

module ResponseEngine
  module PromptFramer
    class << self
      def determine(classification:, context:)
        return :mirror if context[:force_mirror] || classification[:type] == :spiral

        drift     = MissionCore.drift_score
        emotion   = context[:emotional_state].to_sym rescue :neutral
        role      = context[:identity_mode] || MissionCore.active_identity_mode
        trust     = context[:trust_score] || TrainingSystem.trust_score || 0.7
        intent    = classification[:type] || :general

        return :grounding if drift >= 0.8
        return :challenging if trust >= 0.85 && emotion == :avoidant
        return :strategic_redirect if intent == :strategy_request
        return :reflective if intent == :journaling || intent == :daily_checkin

        :mirror
      end
    end
  end
end
