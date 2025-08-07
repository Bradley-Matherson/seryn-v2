# 📁 /seryn/strategy_engine/strategy_registry/strategy_registry.rb

require 'yaml'
require 'fileutils'
require 'time'

module StrategyRegistry
  REGISTRY_PATH = 'data/strategy/global_registry.yml'

  class << self
    def log(entry)
      entry = normalize(entry)
      registry = all
      registry << entry
      write_registry(registry)
    end

    def update(id, updates = {})
      registry = all
      strat = registry.find { |s| s[:id] == id }
      return unless strat

      updates.each { |k, v| strat[k] = v }
      strat[:last_used_at] = Time.now.iso8601
      write_registry(registry)
    end

    def find(id)
      all.find { |s| s[:id] == id }
    end

    def find_by_goal(goal)
      all.select { |s| s[:goal_category]&.to_sym == goal.to_sym }
    end

    def find_by_tag(tag)
      all.select { |s| s[:tags]&.include?(tag.to_sym) }
    end

    def find_user_created_strategies
      all.select { |s| s[:origin] == :user_defined }
    end

    def find_failed_variants(goal)
      all.select do |s|
        s[:goal_category]&.to_sym == goal.to_sym &&
        [:rejected, :failed].include?(s[:status]&.to_sym)
      end
    end

    def delete(id)
      updated = all.reject { |s| s[:id] == id }
      write_registry(updated)
    end

    def all(status_filter = nil)
      FileUtils.mkdir_p(File.dirname(REGISTRY_PATH))
      data = File.exist?(REGISTRY_PATH) ? YAML.load_file(REGISTRY_PATH) : []
      return data unless status_filter
      data.select { |s| s[:status]&.to_sym == status_filter.to_sym }
    end

    def normalize(entry)
      {
        id: entry[:id] || "STRAT-#{Time.now.to_i}-#{rand(1000)}",
        title: entry[:title] || "Untitled Strategy",
        goal_category: entry[:goal_category] || :unspecified,
        tags: entry[:tags] || [],
        origin: entry[:origin] || :user_defined,
        status: entry[:status] || :available,
        strategy_class: entry[:strategy_class] || :tactical,
        created_at: entry[:created_at] || Time.now.iso8601,
        last_used_at: entry[:last_used_at] || Time.now.iso8601,
        modified_by: entry[:modified_by],
        notes: entry[:notes]
      }
    end

    private

    def write_registry(data)
      File.open(REGISTRY_PATH, 'w') { |f| f.write(data.to_yaml) }
    end
  end
end
