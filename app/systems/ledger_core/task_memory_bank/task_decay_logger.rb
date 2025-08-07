# 📘 TaskDecayLogger — Tracks High-Frequency Task Deferrals
# Subcomponent of LedgerCore::TaskMemoryBank

require 'yaml'
require 'fileutils'
require 'date'

module LedgerCore
  module TaskMemoryBank
    module TaskDecayLogger
      LOG_PATH = "./memory/task_memory/task_decay_log.yml"

      class << self
        def record(task)
          FileUtils.mkdir_p(File.dirname(LOG_PATH))
          log = load_log

          entry = {
            title: task[:title],
            priority: task[:priority],
            role_tag: task[:role_tag],
            skip_count: task[:skip_count],
            flagged_on: Date.today.to_s
          }

          log << entry
          File.write(LOG_PATH, log.to_yaml)
        end

        def all
          File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) : []
        end

        def purge_excessive_skips!(threshold = 5)
          log = all
          survivors = log.reject { |t| t[:skip_count].to_i >= threshold }

          File.write(LOG_PATH, survivors.to_yaml)
          survivors
        end

        private

        def load_log
          File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) : []
        end
      end
    end
  end
end
