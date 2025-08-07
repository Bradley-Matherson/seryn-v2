# 📘 ReflectionLog — Logs Reflection Triggers and Prompts
# Subcomponent of LedgerCore::TaskMemoryBank

require 'yaml'
require 'fileutils'
require 'date'

module LedgerCore
  module TaskMemoryBank
    module ReflectionLog
      LOG_PATH = "./memory/task_memory/reflection_triggers.yml"

      class << self
        def record(message:, category:, time:)
          FileUtils.mkdir_p(File.dirname(LOG_PATH))
          log = load_log

          log << {
            prompt: message,
            category: category.to_s,
            timestamp: time,
            day: Date.today.strftime("%A"),
            date: Date.today.to_s
          }

          File.write(LOG_PATH, log.to_yaml)
        end

        def all
          File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) : []
        end

        def by_category(cat)
          all.select { |entry| entry[:category] == cat.to_s }
        end

        private

        def load_log
          File.exist?(LOG_PATH) ? YAML.load_file(LOG_PATH) : []
        end
      end
    end
  end
end
