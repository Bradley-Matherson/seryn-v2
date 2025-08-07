# frozen_string_literal: true

# 🧬 IdentitySpeechMatcher
# Purpose:
# Maps your current identity role to a tone template that matches your psychological mode.
# Enables Seryn to speak in a way that aligns with who you are right now.

module TrainingSystem
  module VoiceTrainer
    module IdentitySpeechMatcher
      IDENTITY_TONE_MAP = {
        father:      "supportive + soft grounding",
        builder:     "energetic + logical cadence",
        strategist:  "reflective + structured",
        provider:    "legacy-driven + purpose-heavy",
        warrior:     "direct + momentum surge",
        default:     "balanced + encouraging"
      }

      def self.map_identity_to_tone(identity)
        IDENTITY_TONE_MAP[identity.to_sym] || IDENTITY_TONE_MAP[:default]
      end

      def self.list_all_styles
        IDENTITY_TONE_MAP
      end
    end
  end
end
