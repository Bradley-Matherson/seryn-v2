# 📁 /seryn/strategy_engine/web_search_augmentor/web_search_augmentor.rb

require_relative '../../../guardian_protocol'
require_relative '../../../context_stack'
require_relative '../../../training_system'
require_relative '../../../output_engine'
require_relative 'web_adapter_router'

require 'time'
require 'json'

module WebSearchAugmentor
  CACHE_PATH = "data/strategy/web_search_cache.json"

  class << self
    def enrich_strategy(topic:, goal:, tags: [], emotional_flags: [], constraints: {})
      return { requires_external_search: false } unless knowledge_gap?(topic)
      return { denied: true, reason: "External lookup disabled by Guardian." } unless GuardianProtocol.allow?(:external_search)

      query = build_query(topic, goal, tags, emotional_flags, constraints)
      cached_result = check_cache(query)

      if cached_result
        log(:cache_hit, topic)
        return cached_result
      end

      raw_results = WebAdapterRouter.search(query: query)
      validated = validate_results(raw_results, topic, tags, constraints)

      GuardianProtocol.log_external_access(:strategy_search, query)
      store_to_cache(query, validated)

      if validated[:requires_approval]
        OutputEngine.queue_for_approval(validated)
      else
        TrainingSystem.log_pattern(:web_lookup_enhanced_strategy, topic)
        validated
      end
    end

    def knowledge_gap?(topic)
      gap_terms = %w[best updated vendor-specific local options 2025 review]
      gap_terms.any? { |word| topic.downcase.include?(word) }
    end

    def build_query(topic, goal, tags, emotion, constraints)
      query = topic.dup
      query << " for #{goal.to_s.gsub('_', ' ')}"
      query << " with #{tags.join(' ')}" unless tags.empty?
      query << " #{constraints[:location]}" if constraints[:location]
      query << " budget friendly" if emotion.include?(:anxiety_reducing)
      query << " 2025" unless query.include?("2025")
      query.strip.squeeze(" ")
    end

    def validate_results(results, topic, tags, constraints)
      results = results.select { |r| r[:confidence_score] >= 0.75 }

      best = results.first
      return {
        requires_approval: true,
        reason: "No high-confidence match",
        results: results
      } unless best

      sensitive = GuardianProtocol.flag_sensitivity?(topic)

      {
        research: {
          topic: topic,
          top_result: best[:title],
          url: best[:url],
          summary: best[:summary],
          confidence_score: best[:confidence_score],
          injected_into: constraints[:injected_into] || "Strategy Phase"
        },
        requires_approval: sensitive,
        flag: sensitive ? :external_data_risk : nil
      }
    end

    def check_cache(query)
      return nil unless File.exist?(CACHE_PATH)
      cache = JSON.parse(File.read(CACHE_PATH)) rescue {}
      cache[query]
    end

    def store_to_cache(query, result)
      cache = File.exist?(CACHE_PATH) ? JSON.parse(File.read(CACHE_PATH)) : {}
      cache[query] = result
      File.write(CACHE_PATH, JSON.pretty_generate(cache))
    end

    def log(event, topic)
      File.open("logs/strategy/web_search_events.log", "a") do |f|
        f.puts "[#{Time.now.iso8601}] #{event.to_s.upcase}: #{topic}"
      end
    end
  end
end
