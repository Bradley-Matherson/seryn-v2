# frozen_string_literal: true

# 🔄 MomentumCycleMapper
# Purpose:
# Analyzes your energy, focus, and burnout rhythms across time using task data,
# emotion trends, and spiral-recovery cycles. Helps Seryn adapt strategies and tone
# to your natural performance cycles.

require_relative '../../ledger_core'
require_relative '../../training_system/memory_pattern_miner/emotion_trajectory_mapper'

module TrainingSystem
  module UserBehaviorProfiler
    module MomentumCycleMapper
      def self.map_cycle_pattern
        task_logs = LedgerCore.fetch_recent_task_logs rescue []
        emotion_logs = MemoryPatternMiner::EmotionTrajectoryMapper.compile_weekly_arc rescue {}

        focus_windows = extract_peak_focus_times(task_logs)
        burnout_threshold = estimate_burnout_threshold(emotion_logs)
        strategy_style = recommend_strategy_style(task_logs)

        {
          peak_hours: focus_windows,
          burnout_after: "#{burnout_threshold} days high-intensity",
          best_strategy_type: strategy_style
        }
      end

      def self.extract_peak_focus_times(tasks)
        hour_blocks = tasks.map do |task|
          Time.parse(task[:timestamp]).hour rescue nil
        end.compact

        histogram = hour_blocks.tally.sort_by { |_, v| -v }.first(2)
        histogram.map { |hour, _| hour_range(hour) }
      end

      def self.hour_range(hour)
        start = hour
        finish = (hour + 2) % 24
        "#{format_hour(start)}–#{format_hour(finish)}"
      end

      def self.format_hour(h)
        Time.new(2000, 1, 1, h).strftime("%l%P").strip
      end

      def self.estimate_burnout_threshold(emotion_logs)
        spirals = emotion_logs[:spiral_events].to_i
        momentum = emotion_logs[:momentum].to_s
        spirals >= 2 ? 3 : (momentum == "rising" ? 5 : 4)
      end

      def self.recommend_strategy_style(tasks)
        milestone_count = tasks.count { |t| t[:tags]&.include?(:milestone) }
        visual_count = tasks.count { |t| t[:tags]&.include?(:visual) }

        return "visual + milestone" if milestone_count > 3 && visual_count > 2
        return "simple checklist" if tasks.size < 5
        "tactical chunking"
      end
    end
  end
end
