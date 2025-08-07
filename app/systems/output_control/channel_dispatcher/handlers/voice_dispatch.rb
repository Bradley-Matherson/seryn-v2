# 📁 seryn/systems/output_control/channel_dispatcher/handlers/voice_dispatch.rb

require_relative "../../../../voice_relay/voice_relay"

module VoiceDispatch
  def self.call(content)
    if VoiceRelay::Controller.voice_ready?
      VoiceRelay::Controller.speak(content)
    else
      puts "🔇 VoiceRelay unavailable. Voice output skipped."
    end
  end
end
