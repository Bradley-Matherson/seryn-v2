# seryn/response_engine/therapeutic_mirror_mode/spiral_breaker_guide.rb

require_relative '../../training/training_system'
require_relative '../../guardian/guardian_protocol'

module ResponseEngine
  module TherapeuticMirrorMode
    module SpiralBreakerGuide
      ACTIONS = [
        :hydration,
        :walk_2_minutes,
        :voice_journaling,
        :stillness_checkin,
        :audio_grounding,
        :box_breathing
      ]

      class << self
        def suggest(context:)
          return :audio_grounding if GuardianProtocol.enforce_soft_response?

          spiral_count = TrainingSystem.spiral_marker_count rescue 0
          trust        = TrainingSystem.trust_score || context[:trust_score] || 0.7

          return :voice_journaling if spiral_count >= 3 && trust >= 0.6
          return :hydration        if spiral_count >= 2 && trust < 0.6
          return :box_breathing    if spiral_count >= 4
          return :none
        end
      end
    end
  end
end
