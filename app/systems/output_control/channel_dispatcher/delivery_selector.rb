# 📁 seryn/systems/output_control/channel_dispatcher/delivery_selector.rb

require_relative "../../../context_stack/context_stack"

module ChannelDispatcher
  module DeliverySelector
    class << self
      def choose_channels(output_package)
        type = output_package[:type]
        identity = ContextStack::Identity.current_role
        emotion = ContextStack::Emotion.current_state
        momentum = ContextStack::Momentum.current_level
        time = Time.now.hour

        # Base channel logic by type
        case type
        when :daily_planner
          return [:terminal, :pdf] if momentum > 3 && identity == :builder
          return [:terminal] if momentum > 2
          return [:voice] if emotion == :spiraling
        when :reflection
          return [:voice] if time < 6 || emotion == :low
          return [:terminal]
        when :strategy_summary
          return [:pdf, :html] if identity == :strategist
          return [:terminal]
        end

        # Fallback if none match
        [:log_only]
      end
    end
  end
end
