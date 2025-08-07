# heartbeat_logger.rb
# ❤️ HeartbeatLogger — logs system status snapshots to detect drift, overload, or failure

require 'fileutils'
require 'yaml'
require 'time'

require_relative "system_state_tracker"
require_relative "mode_flag_controller"

module HeartbeatLogger
  LOG_DIR = "logs/system_state/heartbeat/"

  def self.log_heartbeat
    FileUtils.mkdir_p(LOG_DIR)
    today = Time.now.strftime("%Y-%m-%d")
    path = "#{LOG_DIR}#{today}.log"

    state = SystemStateTracker.all_states
    error = SystemStateTracker.last_error
    guardian_active = ModeFlagController.active?(:emergency_mode) || ModeFlagController.active?(:therapeutic_mode)

    entry = {
      timestamp: Time.now.iso8601,
      systems_alive: state.count { |_k, v| v == :active },
      last_error: error,
      guardian_watch: guardian_active,
      active_modes: ModeFlagController.active_modes,
      full_state: state
    }

    File.open(path, "a") do |file|
      file.puts entry.to_yaml
      file.puts "---"
    end
  end
end
