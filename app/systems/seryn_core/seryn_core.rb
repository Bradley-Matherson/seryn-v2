# 📁 core/seryn_core.rb

require_relative "system_matrix"
require_relative "core_loop"
require_relative "core_dashboard"
require_relative "heartbeat_monitor"
require_relative "loop_triggers"
require_relative "seryn_context_stack"
require_relative "self_update_interface"
require_relative "seryn_voice_router"

module SerynCore
  class << self
    attr_reader :status, :last_input, :last_response

    def boot
      puts "[SerynCore] Booting systems..."

      SystemMatrix.register_all_systems
      HeartbeatMonitor.start
      CoreDashboard.launch
      @status = :active

      puts "[SerynCore] Boot complete. Seryn is now live."
    end

    def receive(input)
      @last_input = input
      SerynContextStack.refresh_context
      CoreLoop.process(input)
    end

    def inject_internal_trigger(trigger)
      puts "[SerynCore] Internal loop trigger: #{trigger}"
      LoopTriggers.handle(trigger)
    end

    def report
      CoreDashboard.status_report
    end

    def shutdown
      HeartbeatMonitor.stop
      @status = :inactive
      puts "[SerynCore] System shut down."
    end
  end
end
