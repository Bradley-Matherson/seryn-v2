# frozen_string_literal: true

# ♻️ RecoveryLoopLogger
# Purpose:
# Logs and analyzes the full spiral → intervention → reflection → action → recovery cycle.
# Used to track average recovery time, what helped, and how to support faster bounce-back.

require_relative '../../memory'
require_relative '../../response_engine'
require_relative '../../guardian_protocol'

module TrainingSystem
  module MemoryPatternMiner
    module RecoveryLoopLogger
      def self.log_recovery_cycles
        logs = Memory.fetch_recent_entries(10)
        spiral_indices = logs.each_index.select { |i| logs[i][:tags]&.include?(:spiral) }

        return { recovery_strength: 0.0, loops: [] } if spiral_indices.empty?

        recovery_loops = spiral_indices.map do |start_i|
          find_recovery_loop(logs, start_i)
        end.compact

        recovery_scores = recovery_loops.map { |loop| loop[:score] }
        average_score = (recovery_scores.sum.to_f / recovery_scores.size).round(2)

        {
          recovery_strength: average_score,
          loops: recovery_loops
        }
      end

      def self.find_recovery_loop(logs, start_i)
        spiral_log = logs[start_i]
        loop = {
          spiral: spiral_log[:content],
          steps: [],
          score: 0.0
        }

        (start_i + 1...logs.size).each do |i|
          entry = logs[i]
          next unless entry

          loop[:steps] << {
            timestamp: entry[:timestamp],
            content: entry[:content],
            tags: entry[:tags]
          }

          if entry[:tags]&.include?(:recovery)
            loop[:score] = evaluate_loop_quality(loop[:steps])
            return loop
          end
        end

        nil # no recovery found
      end

      def self.evaluate_loop_quality(steps)
        reflection_count = steps.count { |s| s[:tags]&.include?(:reflection) }
        action_taken = steps.any? { |s| s[:tags]&.include?(:task_completed) }
        time_span = compute_time_span(steps)

        score = 1.0
        score += 1.0 if reflection_count >= 2
        score += 1.0 if action_taken
        score -= 0.5 if time_span > 3.0 # days

        score.clamp(0.0, 5.0)
      end

      def self.compute_time_span(steps)
        return 0 if steps.empty?

        first = Time.parse(steps.first[:timestamp]) rescue Time.now
        last = Time.parse(steps.last[:timestamp]) rescue Time.now
        duration_days = (last - first) / 86_400.0 # seconds → days
        duration_days.round(2)
      end
    end
  end
end
