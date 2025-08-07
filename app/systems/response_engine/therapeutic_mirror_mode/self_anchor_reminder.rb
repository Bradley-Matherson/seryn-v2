# seryn/response_engine/therapeutic_mirror_mode/self_anchor_reminder.rb

require_relative '../../mission/mission_core'
require_relative '../../recall/recall'

module ResponseEngine
  module TherapeuticMirrorMode
    module SelfAnchorReminder
      class << self
        def pull(context:)
          role   = context[:identity_mode] || MissionCore.active_identity_mode
          pillar = MissionCore.dominant_pillar
          anchor = last_used_anchor || fallback_anchor(role, pillar)

          anchor
        end

        private

        def last_used_anchor
          Recall.last_emotional_anchor  # e.g., :freedom, :legacy, etc.
        end

        def fallback_anchor(role, pillar)
          return :freedom if role == :father && pillar == :freedom
          return :growth  if role == :builder
          return :legacy  if role == :strategist

          :purpose
        end
      end
    end
  end
end
