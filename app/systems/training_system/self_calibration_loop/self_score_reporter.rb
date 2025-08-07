# frozen_string_literal: true

# 📊 SelfScoreReporter
# Purpose:
# Generates and stores a summary report of each self-calibration cycle,
# including tone accuracy, spiral count, trust delta, and drift risk.
# Pushes this data to SerynCore for visual awareness and tracks evolution over time.

require 'yaml'
require 'fileutils'

module TrainingSystem
  module SelfCalibrationLoop
    module SelfScoreReporter
      REPORT_DIR = "logs/training/self_reports"

      def self.generate_report(reflection, adjustments, anomalies)
        FileUtils.mkdir_p(REPORT_DIR)
        date = Time.now.strftime('%Y-%m-%d')
        path = "#{REPORT_DIR}/#{date}.yml"

        summary = {
          calibration_summary: {
            timestamp: Time.now,
            tone_accuracy: calculate_tone_score(reflection),
            goal_alignment: estimate_goal_alignment(reflection),
            drift_events: drift_count(anomalies),
            spiral_triggers_detected: (reflection[:spiral_detected] ? 1 : 0),
            trust_delta: reflection[:trust_change].round(2),
            actions_planned: adjustments[:actions],
            result: adjustments[:result]
          }
        }

        File.write(path, summary.to_yaml)
        push_to_dashboard(summary[:calibration_summary])

        summary
      end

      def self.calculate_tone_score(reflection)
        reflection[:tone_useful] ? "92%" : "65%" # Placeholder values
      end

      def self.estimate_goal_alignment(reflection)
        rate = reflection[:task_completion_rate].to_f
        case rate
        when 0.9..1.0 then "99%"
        when 0.6..0.89 then "88%"
        else "74%"
        end
      end

      def self.drift_count(anomalies)
        anomalies.count { |a| a[:type].to_s.include?("drift") || a[:type] == :trust_decline }
      end

      def self.push_to_dashboard(data)
        SerynCore.receive_calibration_summary(data) if defined?(SerynCore)
      end
    end
  end
end
