# pattern_tracer.rb
# 📊 Tracks confidence trends, input frequency, mood correlation

require 'fileutils'
require 'json'

module InterpreterSystem
  class PatternTracer
    TRACE_DIR = "logs/interpreter/patterns"
    SUMMARY_FILE = "#{TRACE_DIR}/trend_summary.json"

    def self.trace(result, timestamp)
      FileUtils.mkdir_p(TRACE_DIR)

      entry = {
        timestamp: timestamp.iso8601,
        intent: result[:intent],
        confidence: result[:confidence_score],
        time_block: time_bucket(timestamp),
        emotional_state: result.dig(:context, :emotional_state),
        identity_mode: result.dig(:context, :identity_mode),
        origin: result[:origin]
      }

      append_to_file(entry)
    rescue => e
      puts "[PatternTracer::ERROR] #{e.message}"
    end

    def self.time_bucket(time)
      hour = time.hour
      case hour
      when 0..5   then :night
      when 6..11  then :morning
      when 12..17 then :afternoon
      else             :evening
      end
    end

    def self.append_to_file(entry)
      File.open(SUMMARY_FILE, 'a') { |f| f.puts entry.to_json }
    end
  end
end
