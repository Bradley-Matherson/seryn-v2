# 📁 seryn/systems/output_control/output_archive/strategy_snapshot_logger.rb

require "fileutils"
require "yaml"
require "time"

module StrategySnapshotLogger
  OUTPUT_DIR = "outputs/strategy_snapshots"

  class << self
    def save_snapshot(output)
      FileUtils.mkdir_p(OUTPUT_DIR)
      timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
      strategy = extract_strategy_info(output)

      file_name = "#{strategy[:goal_slug]}_#{timestamp}.yml"
      path = File.join(OUTPUT_DIR, file_name)

      File.write(path, strategy.to_yaml)
      puts "📊 Strategy snapshot saved: #{path}"
    end

    private

    def extract_strategy_info(output)
      {
        goal: output[:strategy_focus] || "Unknown Goal",
        goal_slug: (output[:strategy_focus] || "unknown").downcase.strip.gsub(/\s+/, "_"),
        phase: output[:phase] || "N/A",
        completed_steps: output[:completed_steps] || 0,
        remaining_steps: output[:strategy_steps]&.size || 0,
        ledger_linked: output[:ledger_linked] || false,
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
  end
end
