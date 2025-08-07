# frozen_string_literal: true

# 📊 PatternClusterer
# Purpose:
# Groups recurring behavioral tags across task completions, identity shifts,
# journaling inputs, and rhythm logs. Detects cyclic traits and performance waves.

require_relative '../../memory'
require_relative '../../recall'
require_relative '../../ledger_core'

module TrainingSystem
  module MemoryPatternMiner
    module PatternClusterer
      def self.generate_clusters
        task_logs = LedgerCore.fetch_recent_task_logs rescue []
        memory_logs = Memory.fetch_recent_entries(7)

        all_tags = extract_behavioral_tags(task_logs, memory_logs)

        clusters = identify_common_patterns(all_tags)
        timestamp_clusters(clusters)
      end

      def self.extract_behavioral_tags(task_logs, memory_logs)
        tag_stream = []

        task_logs.each do |log|
          tag_stream << {
            type: :task,
            tags: log[:tags] || [],
            momentum: log[:momentum_state],
            identity: log[:identity_mode],
            timestamp: log[:timestamp]
          }
        end

        memory_logs.each do |entry|
          tag_stream << {
            type: :input,
            tags: entry[:reflection_tags] || [],
            emotion: entry[:emotional_state],
            identity: entry[:active_identity],
            timestamp: entry[:timestamp]
          }
        end

        tag_stream
      end

      def self.identify_common_patterns(data)
        clusters = []

        burnouts = data.select { |d| d[:tags].include?(:burnout) }
        if burnouts.size >= 2
          clusters << {
            label: "Burnout Cycle Detected",
            insight: "Multiple burnout tags found in recent history",
            weight: :high
          }
        end

        father_mode_skips = data.count { |d| d[:identity] == :father && d[:type] == :input && (d[:tags] & [:avoidance, :absent]).any? }
        if father_mode_skips >= 2
          clusters << {
            label: "Father Mode Avoidance",
            insight: "Detected journaling or task gaps in Father mode",
            weight: :moderate
          }
        end

        surge_followed_by_crash = detect_surge_crash_pattern(data)
        clusters << surge_followed_by_crash if surge_followed_by_crash

        clusters
      end

      def self.detect_surge_crash_pattern(data)
        recent = data.sort_by { |d| d[:timestamp].to_s }.last(6)

        surge = recent.select { |d| d[:tags].include?(:hyperfocus) }.size
        crash = recent.select { |d| d[:tags].include?(:spiral) || d[:tags].include?(:shutdown) }.size

        if surge >= 2 && crash >= 1
          {
            label: "Surge-Crash Cycle",
            insight: "Detected high momentum followed by emotional crash",
            weight: :high
          }
        else
          nil
        end
      end

      def self.timestamp_clusters(clusters)
        clusters.map do |c|
          c.merge(timestamp: Time.now)
        end
      end
    end
  end
end
