# 📁 seryn/systems/output_control/voice_relay/voice_relay.rb

require_relative "tts_engine"
require_relative "tone_shaper"
require_relative "pace_controller"
require_relative "silence_inserter"

module VoiceRelay
  module Controller
    class << self
      def speak(content)
        return unless voice_ready?

        toned = ToneShaper.apply(content)
        paced = PaceController.adjust(toned)
        final_output = SilenceInserter.insert(paced)

        TTSEngine.speak(final_output)
      end

      def voice_ready?
        TTSEngine.available?
      end
    end
  end
end
