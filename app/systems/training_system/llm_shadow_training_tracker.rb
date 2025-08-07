# frozen_string_literal: true

# 🧠 LLMShadowTrainingTracker (v2)
# Purpose:
# Builds a fully personalized, evolving dataset of prompt-response pairs.
# Tracks phrasing styles, emotional impact, strategic outcome, repeat value, and template-worthiness.
# This becomes the future training source for Seryn's localized LLM.

require 'json'
require 'fileutils'
require 'digest'

module TrainingSystem
  module LLMShadowTrainingTracker
    SHADOW_DATASET_PATH = "data/llm_shadow_dataset.json"

    def self.store_interaction(prompt:, response:, type:, emotion:, success: true, strategy_label: nil, retrain: false, feedback: {})
      return unless high_quality?(prompt, response, success)

      entry = {
        id: generate_id(prompt, response),
        timestamp: Time.now,
        type: type,
        prompt: prompt,
        response: response,
        emotion: emotion,
        success: success,
        strategy_label: strategy_label,
        retrain: retrain,
        feedback: map_feedback(feedback)
      }

      dataset = load_dataset
      dataset << entry
      save_dataset(dataset)
    end

    def self.map_feedback(feedback)
      {
        alignment_score: feedback[:alignment_score] || 0.75,
        emotional_impact: feedback[:emotional_impact] || :neutral,
        task_progress: feedback[:task_progress] || :moderate,
        repeat_modifier: feedback[:repeat_modifier] || 1.0,
        template_seed: feedback[:template_seed] || false,
        repeat_penalty: feedback[:repeat_penalty] || false
      }
    end

    def self.high_quality?(prompt, response, success)
      return false if prompt.strip.length < 20 || response.strip.length < 30
      success || prompt.include?("?") || response.include?("you might")
    end

    def self.generate_id(prompt, response)
      Digest::SHA256.hexdigest("#{prompt}_#{response}_#{Time.now.to_f}")
    end

    def self.load_dataset
      File.exist?(SHADOW_DATASET_PATH) ? JSON.parse(File.read(SHADOW_DATASET_PATH), symbolize_names: true) : []
    end

    def self.save_dataset(dataset)
      FileUtils.mkdir_p(File.dirname(SHADOW_DATASET_PATH))
      File.write(SHADOW_DATASET_PATH, JSON.pretty_generate(dataset))
    end

    def self.fetch_by(filter = {})
      load_dataset.select do |entry|
        filter.all? { |k, v| entry[k] == v }
      end
    end

    def self.fetch_templates
      load_dataset.select { |e| e.dig(:feedback, :template_seed) }
    end

    def self.fetch_retraining_queue
      load_dataset.select { |e| e[:retrain] == true || e.dig(:feedback, :repeat_penalty) }
    end

    def self.dataset_stats
      data = load_dataset
      {
        total_entries: data.size,
        successful: data.count { |d| d[:success] },
        retrain_flagged: data.count { |d| d[:retrain] },
        template_count: data.count { |d| d.dig(:feedback, :template_seed) }
      }
    end
  end
end
