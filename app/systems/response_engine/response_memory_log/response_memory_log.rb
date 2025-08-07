# seryn/response_engine/response_memory_log/response_memory_log.rb

require 'yaml'
require 'fileutils'

module ResponseEngine
  module ResponseMemoryLog
    LOG_PATH = "logs/response/memory_log.yml"

    class << self
      def log(entry)
        FileUtils.mkdir_p(File.dirname(LOG_PATH))
        memory = load_log
        memory << format_entry(entry)
        File.write(LOG_PATH, memory.to_yaml)
      end

      def last_n(n = 10)
        load_log.last(n)
      end

      def recent_successful_phrasing(tone:, role:, type:)
        load_log.reverse.find do |entry|
          entry[:tone] == tone &&
          entry[:role] == role &&
          entry[:prompt_type] == type &&
          entry[:impact] == :calming
        end
      end

      private

      def load_log
        File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) || [] : []
      end

      def format_entry(entry)
        {
          timestamp: Time.now,
          tone: entry[:tone],
          prompt_type: entry[:prompt_type],
          role: entry[:identity_mode],
          trust: entry[:trust_score],
          emotion: entry[:emotional_state],
          impact: entry[:impact] || :unknown
        }
      end
    end
  end
end
