# core/system_router/routing_log_emitter.rb

require_relative '../training_system'
require_relative '../guardian_protocol'

module RoutingLogEmitter
  class << self
    def emit(log_bundle)
      begin
        TrainingSystem.log_route(log_bundle)

        if log_bundle[:guardian_approval]
          GuardianProtocol.record_routing(log_bundle)
        end
      rescue => e
        puts "[RoutingLogEmitter] Logging failed: #{e.message}"
      end
    end
  end
end
