# 📁 seryn/systems/output_control/channel_dispatcher/channel_dispatcher.rb

require_relative "delivery_selector"
require_relative "time_gating_engine"
require_relative "redundancy_controller"
require_relative "channel_handler_map"
require_relative "output_gatekeeper"

module ChannelDispatcher
  module Controller
    class << self
      def dispatch(output_package)
        return :blocked unless OutputGatekeeper.allowed?(output_package)

        # Apply time gate
        return :delayed unless TimeGatingEngine.allow_now?(output_package)

        return :redundant if RedundancyController.already_delivered?(output_package)

        channels = DeliverySelector.choose_channels(output_package)
        return :log_only if channels.empty?

        channels.each do |channel|
          handler = ChannelHandlerMap.handler_for(channel)
          handler.call(output_package[:content]) if handler
        end

        RedundancyController.mark_as_delivered(output_package)
        return :delivered
      end

      def available_channels
        ChannelHandlerMap.available
      end
    end
  end
end
