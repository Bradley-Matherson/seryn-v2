# seryn/response_engine/response_selector/persona_mirror_interface.rb

require_relative '../../mission/mission_core'

module ResponseEngine
  module ResponseSelector
    module PersonaMirrorInterface
      TONE_SIGNATURES = {
        father:     "reflective + grounding",
        builder:    "motivational + direct",
        strategist: "analytical + empowering",
        protector:  "calm + strong",
        companion:  "warm + steady"
      }

      DELIVERY_STYLES = {
        father:     :text_and_audio,
        builder:    :text,
        strategist: :text,
        protector:  :text_and_audio,
        companion:  :text
      }

      OUTPUT_PROFILES = {
        father: {
          default_tone: :grounding,
          preferred_prompt_type: :mirror,
          default_format: :audio_friendly
        },
        builder: {
          default_tone: :direct,
          preferred_prompt_type: :challenge,
          default_format: :markdown
        },
        strategist: {
          default_tone: :strategic,
          preferred_prompt_type: :reflection,
          default_format: :text
        },
        protector: {
          default_tone: :calm,
          preferred_prompt_type: :grounding,
          default_format: :text_and_audio
        },
        companion: {
          default_tone: :gentle,
          preferred_prompt_type: :supportive,
          default_format: :text
        },
        default: {
          default_tone: :neutral,
          preferred_prompt_type: :neutral,
          default_format: :text
        }
      }

      class << self
        def active_identity(context)
          role = context[:identity_mode] || MissionCore.active_identity_mode || :default

          {
            identity: role,
            tone_signature: TONE_SIGNATURES[role] || TONE_SIGNATURES[:companion],
            delivery_method: DELIVERY_STYLES[role] || :text,
            output_profile: OUTPUT_PROFILES[role] || OUTPUT_PROFILES[:default]
          }
        end
      end
    end
  end
end
