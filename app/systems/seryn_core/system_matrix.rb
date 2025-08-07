# 📁 core/system_matrix.rb

require_relative "guardian_protocol"

module SystemMatrix
  @systems = {}

  class << self
    def register(system_key, options = {})
      @systems[system_key] = {
        system: system_key,
        active: options.fetch(:active, true),
        last_heartbeat: Time.now,
        trust_score: options.fetch(:trust_score, 1.0),
        status: :healthy,
        fallback: options[:fallback]
      }

      puts "[SystemMatrix] Registered system: #{system_key}"
    end

    def register_all_systems
      # This should be expanded with all known systems
      register(:ledger_core)
      register(:strategy_engine, fallback: :response_engine)
      register(:guardian_protocol)
      register(:mission_core)
      register(:training_system)
      register(:response_engine)
      register(:interpreter_system)
      register(:system_router)
    end

    def update_heartbeat(system_key)
      return unless @systems[system_key]
      @systems[system_key][:last_heartbeat] = Time.now
    end

    def mark_error(system_key)
      if @systems[system_key]
        @systems[system_key][:status] = :error
        @systems[system_key][:active] = false
      end
    end

    def get_status(system_key)
      @systems[system_key]
    end

    def all_statuses
      @systems
    end

    def health_snapshot
      @systems.transform_values do |sys|
        {
          active: sys[:active],
          status: sys[:status],
          trust: sys[:trust_score],
          last_heartbeat: sys[:last_heartbeat]
        }
      end
    end

    def trusted?(system_key)
      sys = @systems[system_key]
      return false unless sys
      sys[:trust_score] > 0.8 && sys[:status] == :healthy
    end

    def fallback_for(system_key)
      sys = @systems[system_key]
      sys ? sys[:fallback] : nil
    end
  end
end
