# 📁 seryn/systems/output_control/channel_dispatcher/redundancy_controller.rb

require "digest"
require "time"

module ChannelDispatcher
  module RedundancyController
    REDUNDANCY_LOG = {}

    class << self
      def already_delivered?(output_package)
        type = output_package[:type]
        hash = digest(output_package[:content])
        key = "#{type}_#{Date.today}"

        REDUNDANCY_LOG[key] ||= []

        if REDUNDANCY_LOG[key].include?(hash)
          true
        else
          false
        end
      end

      def mark_as_delivered(output_package)
        type = output_package[:type]
        hash = digest(output_package[:content])
        key = "#{type}_#{Date.today}"

        REDUNDANCY_LOG[key] ||= []
        REDUNDANCY_LOG[key] << hash
      end

      private

      def digest(content)
        Digest::SHA256.hexdigest(content.to_s)
      end
    end
  end
end
