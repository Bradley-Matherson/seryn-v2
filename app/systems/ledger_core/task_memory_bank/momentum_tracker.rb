# 📘 MomentumTracker — Logs Streaks, Consistency, and Rhythm Cycles
# Subcomponent of LedgerCore::TaskMemoryBank

require 'yaml'
require 'fileutils'
require 'date'

module LedgerCore
  module TaskMemoryBank
    module MomentumTracker
      STREAK_LOG_PATH = "./memory/task_memory/momentum_streaks.yml"
      CYCLE_LOG_PATH  = "./memory/task_memory/rhythm_cycles.yml"

      class << self
        def record(type:, value:, time:)
          FileUtils.mkdir_p(File.dirname(STREAK_LOG_PATH))
          log = load_streak_log

          log << {
            type: type.to_s,
            value: value,
            timestamp: time,
            date: Date.today.to_s
          }

          File.write(STREAK_LOG_PATH, log.to_yaml)
        end

        def record_cycle(cycle_hash)
          FileUtils.mkdir_p(File.dirname(CYCLE_LOG_PATH))
          log = load_cycle_log

          log << cycle_hash.merge({
            recorded_at: Time.now.utc.iso8601
          })

          File.write(CYCLE_LOG_PATH, log.to_yaml)
        end

        def all_streaks
          File.exist?(STREAK_LOG_PATH) ? YAML.load_file(STREAK_LOG_PATH) : []
        end

        def all_cycles
          File.exist?(CYCLE_LOG_PATH) ? YAML.load_file(CYCLE_LOG_PATH) : []
        end

        private

        def load_streak_log
          File.exist?(STREAK_LOG_PATH) ? YAML.load_file(STREAK_LOG_PATH) : []
        end

        def load_cycle_log
          File.exist?(CYCLE_LOG_PATH) ? YAML.load_file(CYCLE_LOG_PATH) : []
        end
      end
    end
  end
end
