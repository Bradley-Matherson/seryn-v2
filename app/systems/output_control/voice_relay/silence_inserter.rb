# 📁 seryn/systems/output_control/voice_relay/silence_inserter.rb

module SilenceInserter
  class << self
    def insert(text)
      return text unless text.is_a?(String)

      # Insert pauses after headers and reflection prompts
      text = text.gsub(/(Reflection Prompt:|Today’s Focus:|Tasks for Today:)/i, '\1 [pause]')
      text = text.gsub(/\n{2,}/, "\n[pause]\n")   # Add pause between sections

      # Add trailing pause to let thought land
      text += "\n[pause]" unless text.strip.end_with?("[pause]")

      text
    end
  end
end
