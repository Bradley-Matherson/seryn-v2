# seryn/response_engine/prompt_template_loader/delivery_format_router.rb

require_relative '../../mission/mission_core'
require_relative '../../training/training_system'

module ResponseEngine
  module PromptTemplateLoader
    module DeliveryFormatRouter
      class << self
        def format_type(context:)
          role = context[:identity_mode] || MissionCore.active_identity_mode || :default
          trust = context[:trust_score] || TrainingSystem.trust_score || 0.7
          journaling = context[:journaling_mode] || false
          emotion = context[:emotional_state] || :neutral

          return :journal_bubble if journaling
          return :audio_friendly if [:father, :protector].include?(role) && trust >= 0.85
          return :markdown if trust >= 0.9 && role == :builder
          return :text if emotion == :fragile || trust < 0.6

          :text
        end
      end
    end
  end
end
