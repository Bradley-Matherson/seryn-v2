# cycle_history_logger.rb
# 📝 CycleHistoryLogger — logs daily/weekly momentum snapshots for trend reflection

require 'yaml'
require 'fileutils'
require 'time'

module CycleHistoryLogger
  LOG_PATH = "logs/context/momentum_cycles.yml"
  MAX_ENTRIES = 300

  def self.log(snapshot)
    FileUtils.mkdir_p("logs/context")
    log = load_history

    entry = {
      timestamp: Time.now.iso8601,
      score: snapshot[:score],
      trend: snapshot[:trend],
      burnout: snapshot[:burnout_warning],
      push_clearance: snapshot[:push_clearance]
    }

    log << entry
    log.shift while log.size > MAX_ENTRIES

    File.write(LOG_PATH, log.to_yaml)
  end

  def self.load_history
    return [] unless File.exist?(LOG_PATH)
    YAML.load_file(LOG_PATH) || []
  end
end
