# role_activation_log.rb
# 📘 Subcomponent: RoleActivationLog — logs each identity switch

require 'fileutils'
require 'time'
require 'yaml'

module RoleActivationLog
  LOG_PATH = "logs/context/identity_role_log.yml"
  @last_logged_role = nil

  def self.log_if_changed(current_role)
    return if @last_logged_role == current_role
    FileUtils.mkdir_p("logs/context")
    entry = {
      timestamp: Time.now.iso8601,
      role: current_role
    }
    File.open(LOG_PATH, "a") { |f| f.puts entry.to_yaml + "---" }
    @last_logged_role = current_role
    ModeDurationTimer.reset_timer
  end
end
