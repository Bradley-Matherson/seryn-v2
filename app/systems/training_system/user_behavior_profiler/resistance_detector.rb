# frozen_string_literal: true

# ⚠️ ResistanceDetector
# Purpose:
# Identifies patterns of avoidance, emotional resistance, and skipped tasks.
# Helps Seryn understand what overwhelms or drains you — and adapt strategy, tone, and entry points.

require_relative '../../memory'
require_relative '../../ledger_core'
require 'set'

module TrainingSystem
  module UserBehaviorProfiler
    module ResistanceDetector
      def self.scan_for_avoidance
        task_logs = LedgerCore.fetch_recent_task_logs rescue []
        journal_logs = Memory.fetch_recent_entries(7)

        skipped = detect_frequent_skips(task_logs)
        journaling_resistance = detect_journaling_resistance(journal_logs)
        emotional_links = correlate_emotions_with_avoidance(journal_logs, skipped)

        (skipped + journaling_resistance + emotional_links).uniq
      end

      def self.detect_frequent_skips(tasks)
        skip_map = Hash.new(0)

        tasks.each do |task|
          next unless task[:result] == :skipped || task[:result] == :ignored
          type = task[:type] || :unspecified
          skip_map[type] += 1
        end

        skip_map.map do |type, freq|
          {
            type: type,
            frequency: :weekly,
            reason: :skipped_frequently
          }
        end
      end

      def self.detect_journaling_resistance(entries)
        time_blocks = entries.group_by { |e| Time.parse(e[:timestamp]).strftime("%A") rescue "Unknown" }
        empty_days = time_blocks.select { |_day, logs| logs.none? { |l| l[:type] == :journal } }

        return [] if empty_days.empty?

        [{
          type: :journaling,
          frequency: :sporadic,
          reason: :inconsistent_entries
        }]
      end

      def self.correlate_emotions_with_avoidance(entries, skip_patterns)
        resistance_flags = []

        emotional_blocks = entries.select { |e| e[:emotional_state] == :overwhelmed || e[:tags]&.include?(:avoidance) }
        keywords = Set.new(%w[budget finances debt reset pressure])

        emotional_blocks.each do |entry|
          if entry[:content].to_s.downcase.split.any? { |word| keywords.include?(word) }
            resistance_flags << {
              type: :financial_review,
              frequency: :weekly,
              emotion_linked: :overwhelm
            }
          end
        end

        resistance_flags
      end
    end
  end
end
