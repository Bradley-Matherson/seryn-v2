# frozen_string_literal: true

# 🧠 EmotionTrajectoryMapper
# Purpose:
# Builds a rolling emotional arc across journal entries, spiral flags,
# mood metadata, and recovery moments. Detects trajectory strength, burnout buildup,
# and recovery efficiency for the current week.

require_relative '../../memory'
require_relative '../../recall'
require 'date'

module TrainingSystem
  module MemoryPatternMiner
    module EmotionTrajectoryMapper
      def self.compile_weekly_arc
        entries = Memory.fetch_recent_entries(7)
        days = group_by_day(entries)

        trajectory = days.map do |date, logs|
          mood = dominant_emotion(logs)
          spiral_count = logs.count { |l| l[:tags]&.include?(:spiral) }
          recovery_events = logs.count { |l| l[:tags]&.include?(:recovery) }

          {
            date: date,
            dominant_emotion: mood,
            spiral_events: spiral_count,
            recovery_events: recovery_events
          }
        end

        summary = summarize_trajectory(trajectory)
        summary
      end

      def self.group_by_day(entries)
        entries.group_by do |entry|
          Date.parse(entry[:timestamp].to_s).strftime('%Y-%m-%d') rescue 'unknown'
        end
      end

      def self.dominant_emotion(logs)
        mood_counts = logs.map { |l| l[:emotional_state] }.compact.tally
        return :unknown if mood_counts.empty?
        mood_counts.max_by { |_, count| count }.first
      end

      def self.summarize_trajectory(daily)
        all_moods = daily.map { |d| d[:dominant_emotion] }.compact
        all_spirals = daily.sum { |d| d[:spiral_events] }
        all_recoveries = daily.sum { |d| d[:recovery_events] }

        # Placeholder logic for arc momentum
        momentum = if all_recoveries > all_spirals
                     :rising
                   elsif all_spirals > 2
                     :declining
                   else
                     :flat
                   end

        {
          dominant_emotion: all_moods.last || :neutral,
          momentum: momentum,
          spiral_events: all_spirals,
          recovery_time_avg: compute_recovery_average(daily)
        }
      end

      def self.compute_recovery_average(daily)
        days_with_recovery = daily.select { |d| d[:recovery_events] > 0 }.size
        return 0 if days_with_recovery.zero?
        (7.0 / days_with_recovery).round(1)
      end
    end
  end
end
