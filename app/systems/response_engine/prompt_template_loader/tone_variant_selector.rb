# seryn/response_engine/prompt_template_loader/tone_variant_selector.rb

require_relative '../../context/context_stack'
require_relative '../../training/training_system'
require_relative '../../guardian/guardian_protocol'
require_relative '../../mission/mission_core'

module ResponseEngine
  module PromptTemplateLoader
    module ToneVariantSelector
      TONE_MATRIX = {
        father: {
          stable: :grounding,
          spiral: :gentle,
          high_trust: :reassuring
        },
        builder: {
          stable: :motivational,
          spiral: :supportive,
          high_trust: :direct
        },
        strategist: {
          stable: :strategic,
          spiral: :soft_logical,
          high_trust: :empowering
        },
        protector: {
          stable: :calm,
          spiral: :soothing,
          high_trust: :authoritative
        },
        companion: {
          stable: :curious,
          spiral: :gentle,
          high_trust: :warm
        },
        default: {
          stable: :neutral,
          spiral: :gentle,
          high_trust: :curious
        }
      }

      class << self
        def select_tone(context:)
          return :soft if GuardianProtocol.enforce_soft_response?

          role   = context[:identity_mode] || MissionCore.active_identity_mode || :default
          emotion = context[:emotional_state] || :neutral
          trust = context[:trust_score] || TrainingSystem.trust_score || 0.7
          spiral = context[:mood_spiral] || TrainingSystem.spiral_flag?

          tone_group = TONE_MATRIX[role.to_sym] || TONE_MATRIX[:default]

          if spiral
            tone_group[:spiral]
          elsif trust >= 0.85
            tone_group[:high_trust]
          else
            tone_group[:stable]
          end
        end
      end
    end
  end
end
