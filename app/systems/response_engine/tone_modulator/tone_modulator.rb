# seryn/response_engine/tone_modulator/tone_modulator.rb

require_relative '../../guardian/guardian_protocol'
require_relative '../../training/training_system'
require_relative '../../mission/mission_core'

module ResponseEngine
  module ToneModulator
    TONE_PROFILE = {
      father: {
        confident: :grounded,
        calm:      :gentle,
        spiral:    :soothing
      },
      builder: {
        confident: :direct,
        calm:      :strategic,
        spiral:    :calm
      },
      strategist: {
        confident: :precise,
        calm:      :measured,
        spiral:    :observational
      },
      default: {
        confident: :clear,
        calm:      :neutral,
        spiral:    :gentle
      }
    }

    class << self
      def determine(classification:, context:)
        return :soft if GuardianProtocol.enforce_soft_response?

        trust   = context[:trust_score] || TrainingSystem.trust_score || 0.7
        spiral  = classification[:tags]&.include?(:spiral_risk)
        role    = context[:identity_mode] || MissionCore.active_identity_mode || :default

        tone_group = TONE_PROFILE[role.to_sym] || TONE_PROFILE[:default]

        if spiral
          tone_group[:spiral]
        elsif trust >= 0.85
          tone_group[:confident]
        else
          tone_group[:calm]
        end
      end
    end
  end
end
