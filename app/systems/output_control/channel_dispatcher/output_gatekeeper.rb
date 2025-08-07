# 📁 seryn/systems/output_control/channel_dispatcher/output_gatekeeper.rb

require_relative "../../../guardian_protocol/guardian_protocol"
require_relative "../../../context_stack/context_stack"

module ChannelDispatcher
  module OutputGatekeeper
    class << self
      def allowed?(output_package)
        type = output_package[:type]
        return false if blocked_by_guardian?(type)
        return false if reflection_saturated?(type)

        true
      end

      private

      def blocked_by_guardian?(type)
        GuardianProtocol::Controller.block_output?(type: type)
      rescue
        false # Fail-safe: don't block unless clearly triggered
      end

      def reflection_saturated?(type)
        return false unless type == :reflection

        ContextStack::Counters.reflections_today >= ContextStack::Limits.max_daily_reflections
      rescue
        false
      end
    end
  end
end
