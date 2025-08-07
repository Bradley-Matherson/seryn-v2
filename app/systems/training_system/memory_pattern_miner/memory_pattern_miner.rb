# frozen_string_literal: true

# 🧠 MemoryPatternMiner — Subsystem Controller
# Purpose:
# Central coordinator for emotional and behavioral pattern mining.
# Delegates analysis to specialized submodules and aggregates results
# for TrainingSystem and other connected systems.

require_relative './emotion_trajectory_mapper'
require_relative './pattern_clusterer'
require_relative './trigger_linker'
require_relative './mission_drift_detector'
require_relative './recovery_loop_logger'

module TrainingSystem
  module MemoryPatternMiner
    PATTERN_OUTPUT_PATH = "data/pattern_logs.json"

    def self.run_weekly_scan
      results = {
        timestamp: Time.now,
        emotion_trajectory: EmotionTrajectoryMapper.compile_weekly_arc,
        behavior_clusters: PatternClusterer.generate_clusters,
        trigger_chains: TriggerLinker.compile_trigger_links,
        mission_drift: MissionDriftDetector.analyze_alignment,
        recovery_metrics: RecoveryLoopLogger.log_recovery_cycles
      }

      store_results(results)
      forward_to_integrations(results)
      results
    end

    def self.store_results(data)
      existing = File.exist?(PATTERN_OUTPUT_PATH) ? JSON.parse(File.read(PATTERN_OUTPUT_PATH), symbolize_names: true) : []
      existing << data
      File.write(PATTERN_OUTPUT_PATH, JSON.pretty_generate(existing))
    end

    def self.forward_to_integrations(data)
      GuardianProtocol.receive_pattern_data(data) if defined?(GuardianProtocol)
      ResponseEngine.receive_emotion_data(data) if defined?(ResponseEngine)
      MissionCore.receive_drift_warning(data[:mission_drift]) if defined?(MissionCore)
      SerynCore.refresh_pattern_awareness(data) if defined?(SerynCore)
    end
  end
end
