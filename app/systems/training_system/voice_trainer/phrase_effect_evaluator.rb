# frozen_string_literal: true

# 📐 PhraseEffectEvaluator
# Purpose:
# Scores prompt phrasing patterns based on outcome behavior, emotional stability,
# and follow-up action. Helps refine which structures are most effective for you.

require_relative '../../memory'
require_relative '../../ledger_core'

module TrainingSystem
  module VoiceTrainer
    module PhraseEffectEvaluator
      PHRASE_STYLES = {
        reflective:  [/what would happen if/i, /have you noticed/i],
        suggestive:  [/have you thought about/i, /you might try/i],
        declarative: [/you need to/i, /you are/i],
        open_prompt: [/how might/i, /is there a way/i],
        motivational: [/let’s/, /we will/, /together/]
      }

      def self.score_last_prompt(prompt)
        style = detect_style(prompt)
        effectiveness = measure_effectiveness(style)

        {
          style: style,
          effectiveness: effectiveness
        }
      end

      def self.detect_style(prompt)
        PHRASE_STYLES.each do |label, patterns|
          return label if patterns.any? { |regex| prompt =~ regex }
        end
        :unknown
      end

      def self.measure_effectiveness(style)
        logs = Memory.fetch_recent_entries(7)
        task_logs = LedgerCore.fetch_recent_task_logs rescue []

        matching_logs = logs.select do |log|
          log[:last_prompt_style]&.to_sym == style
        end

        completions = task_logs.select do |task|
          [:completed, :executed].include?(task[:result]) &&
          Time.parse(task[:timestamp]) > Time.now - 86_400
        end

        if completions.size >= 3
          :strong
        elsif completions.size >= 1
          :moderate
        else
          :weak
        end
      end

      def self.summarize_phrase_performance
        logs = Memory.fetch_recent_entries(14)
        grouped = logs.group_by { |e| e[:last_prompt_style] }

        grouped.transform_values do |entries|
          {
            total: entries.size,
            recent_emotion: entries.last[:emotional_state]
          }
        end
      end
    end
  end
end
