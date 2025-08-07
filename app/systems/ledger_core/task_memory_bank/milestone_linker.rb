# 📘 MilestoneLinker — Links Daily Tasks to Active Milestones
# Subcomponent of LedgerCore::TaskMemoryBank

require 'yaml'
require 'fileutils'
require 'date'

module LedgerCore
  module TaskMemoryBank
    module MilestoneLinker
      LOG_PATH = "./memory/task_memory/task_milestone_links.yml"

      class << self
        def record(tagged_tasks)
          FileUtils.mkdir_p(File.dirname(LOG_PATH))
          log = load_log

          tagged_tasks.each do |entry|
            next unless entry[:milestone]

            log << {
              title: entry[:title],
              milestone: entry[:milestone],
              role: entry[:role],
              priority: entry[:priority],
              date: Date.today.to_s
            }
          end

          File.write(LOG_PATH, log.to_yaml)
        end

        def for_milestone(id)
          all.select { |entry| entry[:milestone] == id.to_s }
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
