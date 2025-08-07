# frozen_string_literal: true

# 📊 ToneFeedbackLogger
# Purpose:
# Tracks the outcome of Seryn’s tone and phrasing over time.
# Measures whether tones build trust, promote journaling, reduce spirals, or cause friction.

require 'json'

module TrainingSystem
  module VoiceTrainer
    module ToneFeedbackLogger
      FEEDBACK_LOG_PATH = "data/tone_feedback_log.json"

      def self.log_feedback_event(update)
        entry = {
          timestamp: Time.now,
          tone_used: update[:last_prompt_style],
          next_style: update[:next_style],
          identity: update[:current_identity],
          trust_score: update[:trust_score],
          remix_variant: update[:remix_variant],
          outcome: classify_outcome(update)
        }

        existing = load_log
        existing << entry
        File.write(FEEDBACK_LOG_PATH, JSON.pretty_generate(existing))
      end

      def self.classify_outcome(update)
        if update[:trust_score] >= 0.85
          :high_reflection
        elsif update[:trust_score] <= 0.6
          :user_friction
        else
          :neutral_effect
        end
      end

      def self.load_log
        File.exist?(FEEDBACK_LOG_PATH) ? JSON.parse(File.read(FEEDBACK_LOG_PATH), symbolize_names: true) : []
      end

      def self.aggregate_stats
        data = load_log

        {
          total_prompts: data.count,
          high_reflection: data.count { |d| d[:outcome] == :high_reflection },
          user_friction: data.count { |d| d[:outcome] == :user_friction },
          most_used_tone: data.map { |d| d[:tone_used] }.compact.tally.max_by { |_, v| v }&.first
        }
      end
    end
  end
end
