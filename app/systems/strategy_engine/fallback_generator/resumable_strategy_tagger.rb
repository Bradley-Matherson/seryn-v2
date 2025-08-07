# 📁 core/strategy/fallback_generator/resumable_strategy_tagger.rb

require 'yaml'
require 'fileutils'
require 'time'

module ResumableStrategyTagger
  QUEUE_PATH = 'data/strategy/fallback_queue.yml'

  class << self
    def store(original_strategy, resume_condition)
      entry = format_entry(original_strategy, resume_condition)
      write_to_queue(entry)
    end

    def format_entry(strategy, condition)
      {
        strategy_id: strategy[:strategy_id] || "untracked_#{Time.now.to_i}",
        description: strategy[:description],
        blocked_on: Time.now.iso8601,
        resume_condition: condition,
        tags: strategy[:tags] || [],
        attempts: (strategy[:attempts] || 0) + 1
      }
    end

    def write_to_queue(entry)
      FileUtils.mkdir_p(File.dirname(QUEUE_PATH))
      existing = File.exist?(QUEUE_PATH) ? YAML.load_file(QUEUE_PATH) : []
      updated = existing.push(entry)
      File.open(QUEUE_PATH, 'w') { |f| f.write(updated.to_yaml) }
    end
  end
end
