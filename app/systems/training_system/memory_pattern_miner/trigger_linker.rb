# frozen_string_literal: true

# 🎯 TriggerLinker
# Purpose:
# Links patterns between stimulus (input), response (emotion), and result (task outcome or trust shift).
# Helps build predictive insight: “When X happens, Y tends to follow.”

require_relative '../../memory'
require_relative '../../ledger_core'
require_relative '../../strategy_engine'

module TrainingSystem
  module MemoryPatternMiner
    module TriggerLinker
      def self.compile_trigger_links
        recent_inputs = Memory.fetch_recent_entries(7)
        recent_tasks = LedgerCore.fetch_recent_task_logs rescue []
        strategy_data = StrategyEngine.fetch_recent_decisions rescue []

        links = []

        links += link_input_to_emotion(recent_inputs)
        links += link_strategy_to_engagement(strategy_data, recent_inputs)
        links += link_emotion_to_task_outcome(recent_inputs, recent_tasks)

        links.compact.uniq
      end

      def self.link_input_to_emotion(entries)
        entries.map do |entry|
          next unless entry[:type] == :input && entry[:emotional_state]

          {
            trigger: entry[:content].slice(0, 40),
            result: entry[:emotional_state],
            pattern: "Input → Emotion",
            timestamp: entry[:timestamp]
          }
        end
      end

      def self.link_strategy_to_engagement(strategies, inputs)
        links = []

        strategies.each do |s|
          next unless s[:suggestion_type] && s[:timestamp]

          matching_entry = inputs.find do |e|
            e[:timestamp] > s[:timestamp] &&
            e[:content]&.include?(s[:suggestion_type].to_s)
          end

          links << {
            trigger: s[:suggestion_type],
            result: matching_entry ? :engaged : :ignored,
            pattern: "Strategy → Engagement",
            timestamp: s[:timestamp]
          }
        end

        links
      end

      def self.link_emotion_to_task_outcome(inputs, tasks)
        links = []

        inputs.each do |entry|
          next unless entry[:emotional_state] && entry[:timestamp]

          nearby_task = tasks.find do |t|
            t[:timestamp] > entry[:timestamp] &&
            (Time.parse(t[:timestamp]) - Time.parse(entry[:timestamp])) < 3600
          end

          if nearby_task
            links << {
              trigger: entry[:emotional_state],
              result: nearby_task[:result] || :unknown,
              pattern: "Emotion → Task Outcome",
              timestamp: nearby_task[:timestamp]
            }
          end
        end

        links
      end
    end
  end
end
