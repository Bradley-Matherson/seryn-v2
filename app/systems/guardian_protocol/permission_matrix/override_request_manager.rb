# seryn/guardian_protocol/permission_matrix/override_request_manager.rb

require 'json'
require 'fileutils'

module OverrideRequestManager
  LOG_DIR = "logs/guardian/overrides"

  def self.initiate(system:, reason:)
    puts "⚠️  Permission denied for: #{system}"
    puts "🛑  Reason: #{reason}"
    puts "❓ Do you want to override this block? (yes/no)"

    input = gets.chomp.downcase
    allowed = input == "yes"

    log_override(system: system, reason: reason, approved: allowed)

    if allowed
      {
        override_granted: true,
        allowed: true,
        reason: "Manual override approved"
      }
    else
      {
        override_granted: false,
        allowed: false,
        reason: "Manual override denied"
      }
    end
  end

  def self.log_override(system:, reason:, approved:)
    FileUtils.mkdir_p(LOG_DIR)
    timestamp = Time.now.strftime('%Y-%m-%d-%H%M%S')
    path = File.join(LOG_DIR, "#{system}_#{timestamp}.json")

    data = {
      system: system,
      reason: reason,
      approved: approved,
      timestamp: Time.now
    }

    File.open(path, 'w') do |f|
      f.puts(JSON.pretty_generate(data))
    end
  rescue => e
    puts "⚠️ Failed to log override: #{e.message}"
  end
end
