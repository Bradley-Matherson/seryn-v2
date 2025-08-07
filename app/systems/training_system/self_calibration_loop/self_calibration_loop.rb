# frozen_string_literal: true

# 🧠 SelfCalibrationLoop — Subsystem Controller
# Purpose:
# Orchestrates daily self-checks and internal tuning based on all connected systems.
# Ensures Seryn evolves with you by learning from outcomes, feedback, and patterns.

require_relative './daily_reflection_scanner'
require_relative './behavioral_adjustment_planner'
require_relative './anomaly_detector'
require_relative './self_score_reporter'
require_relative './training_recall_updater'

module TrainingSystem
  module SelfCalibrationLoop
    def self.run_end_of_day_calibration
      reflection = DailyReflectionScanner.compile_system_status
      adjustments = BehavioralAdjustmentPlanner.plan_from(reflection)
      anomalies = AnomalyDetector.flag_irregularities(reflection, adjustments)
      report = SelfScoreReporter.generate_report(reflection, adjustments, anomalies)

      TrainingRecallUpdater.apply_learnings(reflection, adjustments, anomalies)
      report
    end

    def self.manual_trigger(reason: "user_command")
      reflection = DailyReflectionScanner.compile_system_status
      adjustments = BehavioralAdjustmentPlanner.plan_from(reflection)
      SelfScoreReporter.generate_report(reflection, adjustments, [])
      TrainingRecallUpdater.apply_learnings(reflection, adjustments, [])
      { triggered_by: reason, success: true }
    end
  end
end
