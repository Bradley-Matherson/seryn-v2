# 📘 RoleUsageLogger — Logs Role Gaps and Reinforcements
# Subcomponent of LedgerCore::TaskMemoryBank

require 'yaml'
require 'fileutils'
require 'date'

module LedgerCore
  module TaskMemoryBank
    module RoleUsageLogger
      LOG_PATH = "./memory/task_memory/role_usage_log.yml"

      class << self
        def record(role:, days:, time:)
          FileUtils.mkdir_p(File.dirname(LOG_PATH))
          log = load_log

          log << {
            role: role.to_s,
            days_inactive: days,
            flagged_at: time
          }

          File.write(LOG_PATH, log.to_yaml)
        end

        def last_gap(role)
          return nil unless File.exist?(LOG_PATH)
          log = YAML.load_file(LOG_PATH)
          entries = log.select { |e| e[:role] == role.to_s }
          entries.last
        end

        def all
          File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) : []
        end

        private

        def load_log
          File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) : []
        end
      end
    end
  end
end
