# 📁 seryn/systems/output_control/output_archive/voice_transcript_saver.rb

require "fileutils"
require "time"

module VoiceTranscriptSaver
  OUTPUT_DIR = "outputs/voice"

  class << self
    def save_voice(output)
      FileUtils.mkdir_p(OUTPUT_DIR)
      timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
      base_name = "#{timestamp}_#{output[:type]}_#{output[:tone] || 'default'}"

      # Save raw text
      save_text(base_name, output[:content])

      # Save simulated mp3
      save_mock_audio(base_name, output[:content])
    end

    private

    def save_text(filename, text)
      path = File.join(OUTPUT_DIR, "#{filename}.txt")
      File.write(path, text)
    end

    def save_mock_audio(filename, text)
      mp3_path = File.join(OUTPUT_DIR, "#{filename}.mp3")

      # Simulate MP3 creation
      File.write(mp3_path, "[Simulated audio for voice output]\n#{text}")
      puts "🎧 Voice output stored at: #{mp3_path}"
    end
  end
end
