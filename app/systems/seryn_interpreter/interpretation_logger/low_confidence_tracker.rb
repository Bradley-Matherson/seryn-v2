# low_confidence_tracker.rb
# ⚠️ Logs interpretations under confidence threshold for review or retraining

require 'fileutils'
require 'json'

module InterpreterSystem
  class LowConfidenceTracker
    TRACKER_FILE = "logs/interpreter/low_confidence.log"
    THRESHOLD = 0.60

    def self.flag(result, timestamp)
      return unless result[:confidence_score] < THRESHOLD

      FileUtils.mkdir_p(File.dirname(TRACKER_FILE))

      entry = {
        timestamp: timestamp.iso8601,
        input: result[:input],
        intent: result[:intent],
        confidence: result[:confidence_score],
        routed_to: result[:routed_to],
        used_llm: result[:used_llm],
        origin: result[:origin]
      }

      File.open(TRACKER_FILE, 'a') { |f| f.puts entry.to_json }
    rescue => e
      puts "[LowConfidenceTracker::ERROR] #{e.message}"
    end

    def self.purge
      File.delete(TRACKER_FILE) if File.exist?(TRACKER_FILE)
    end
  end
end
