# 📁 core/heartbeat_monitor.rb

require_relative "system_matrix"
require_relative "guardian_protocol"

module HeartbeatMonitor
  @running = false
  @interval = 15 # seconds between checks
  @thread = nil

  class << self
    def start
      return if @running
      puts "[HeartbeatMonitor] Starting..."
      @running = true

      @thread = Thread.new do
        while @running
          perform_check
          sleep @interval
        end
      end
    end

    def stop
      @running = false
      @thread&.kill
      puts "[HeartbeatMonitor] Stopped."
    end

    def perform_check
      now = Time.now
      SystemMatrix.all_statuses.each do |key, info|
        next unless info[:active]

        last_beat = info[:last_heartbeat]
        delta = now - last_beat

        if delta > (@interval * 2)
          puts "[HeartbeatMonitor] ❌ No response from #{key} (Δ=#{delta.round}s)"
          SystemMatrix.mark_error(key)
          GuardianProtocol.flag(key, :heartbeat_missed)

          fallback = SystemMatrix.fallback_for(key)
          if fallback
            puts "[HeartbeatMonitor] → Triggering fallback: #{fallback}"
            fallback_message = "[#{key}] is offline. Switching temporarily to fallback system."
            fallback_system = Object.const_get(camelize(fallback.to_s))
            fallback_system.call(:notify, { message: fallback_message })
          end
        else
          SystemMatrix.update_heartbeat(key)
        end
      end
    end

    private

    def camelize(str)
      str.split('_').map(&:capitalize).join
    end
  end
end
