# 📁 seryn/systems/output_control/voice_relay/tts_engine.rb

module TTSEngine
  class << self
    def speak(text)
      if ENV["SPEECH_MODE"] == "simulated"
        simulate(text)
      else
        system("say '#{text.gsub("'", "")}'")  # MacOS native TTS
      end
    rescue => e
      puts "❌ TTS error: #{e.message}"
    end

    def available?
      ENV["SPEECH_MODE"] != "disabled"
    end

    private

    def simulate(text)
      puts "\n🎧 [Simulated Voice Output]"
      puts "-" * 40
      puts text
      puts "-" * 40
    end
  end
end
