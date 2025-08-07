# system_activity_feed.rb
# 🔁 SystemActivityFeed — master controller for internal system awareness

require_relative "system_state_tracker"
require_relative "mode_flag_controller"
require_relative "heartbeat_logger"
require_relative "fallback_eligibility_registry"
require_relative "system_activity_overlay"

module SystemActivityFeed
  def self.refresh
    HeartbeatLogger.log_heartbeat
    SystemActivityOverlay.update_overlay
  end

  def self.current_focus
    SystemActivityOverlay.focus
  end

  def self.snapshot
    {
      total_active: SystemStateTracker.active_count,
      fallback_engaged: FallbackEligibilityRegistry.any_fallback_engaged?,
      error_detected: SystemStateTracker.last_error,
      current_focus: current_focus,
      active_modes: ModeFlagController.active_modes
    }
  end
end
