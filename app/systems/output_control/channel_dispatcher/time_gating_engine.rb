# 📁 seryn/systems/output_control/channel_dispatcher/time_gating_engine.rb

require_relative "../../../context_stack/context_stack"

module ChannelDispatcher
  module TimeGatingEngine
    NIGHT_HOURS = (0..5).freeze

    class << self
      def allow_now?(output_package)
        time = Time.now
        emotion = ContextStack::Emotion.current_state
        type = output_package[:type]
        silent_mode = ContextStack::Settings.silent_mode?

        return false if silent_mode && type == :reflection

        if NIGHT_HOURS.include?(time.hour)
          return false if emotion == :low || emotion == :spiraling
          return true if type == :log_only || type == :strategy_summary
        end

        # Special delay logic for reflection-type at night
        if type == :reflection && emotion != :stable
          return false
        end

        true
      end
    end
  end
end
