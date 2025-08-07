# seryn/response_engine/therapeutic_mirror_mode/trigger_detector.rb

require_relative '../../training/training_system'
require_relative '../../guardian/guardian_protocol'
require_relative '../../mission/mission_core'

module ResponseEngine
  module TherapeuticMirrorMode
    module TriggerDetector
      class << self
        def activate?(input:, context:)
          journal_trigger = journaling_with_fragility?(context)
          spiral_trigger  = emotional_instability?(context)
          guardian_trigger = GuardianProtocol.enforce_soft_response?
          mission_trigger  = MissionCore.drift_score >= 0.8

          journal_trigger || spiral_trigger || guardian_trigger || mission_trigger
        end

        private

        def journaling_with_fragility?(context)
          intent = context[:intent_tag]
          emotion = context[:emotional_state]

          intent == :journaling &&
            %i[drained numb guilt stuck burnout].include?(emotion)
        end

        def emotional_instability?(context)
          context[:mood_spiral] ||
            TrainingSystem.spiral_flag? ||
            %i[frozen hopeless spiraling].include?(context[:emotional_state])
        end
      end
    end
  end
end
