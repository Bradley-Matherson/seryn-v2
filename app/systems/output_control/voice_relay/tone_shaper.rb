# 📁 seryn/systems/output_control/voice_relay/tone_shaper.rb

require_relative "../../../context_stack/context_stack"

module ToneShaper
  TONE_TAGS = {
    calm:     "[Tone: Calm] ",
    grounded: "[Tone: Grounded] ",
    firm:     "[Tone: Firm] ",
    warm:     "[Tone: Warm] ",
    gentle:   "[Tone: Gentle] ",
    assertive:"[Tone: Assertive] ",
    default:  ""
  }

  class << self
    def apply(content)
      tone = ContextStack::Tone.current_voice_tone rescue :default
      prefix = TONE_TAGS[tone] || TONE_TAGS[:default]
      "#{prefix}#{content}"
    end
  end
end
