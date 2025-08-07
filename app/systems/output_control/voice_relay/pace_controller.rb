# 📁 seryn/systems/output_control/voice_relay/pace_controller.rb

require_relative "../../../context_stack/context_stack"

module PaceController
  PACE_TAGS = {
    slow:    "[Pace: Slow] ",
    steady:  "[Pace: Steady] ",
    fast:    "[Pace: Fast] ",
    default: ""
  }

  class << self
    def adjust(content)
      pace = calculate_pace
      prefix = PACE_TAGS[pace] || PACE_TAGS[:default]
      "#{prefix}#{content}"
    end

    private

    def calculate_pace
      emotion = ContextStack::Emotion.current_state rescue :stable
      momentum = ContextStack::Momentum.current_level rescue 3.0

      return :slow    if emotion == :spiraling || momentum < 2
      return :fast    if momentum > 4.5
      return :steady
    end
  end
end
