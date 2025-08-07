# core/mission_drift_detector.rb

require "date"
require_relative "mission_anchor_store"
require_relative "guardian_protocol"
require_relative "training_system"

module MissionDriftDetector
  extend self

  DRIFT_LOG = "data/mission_drift_log.txt"
  MAX_HISTORY = 50

  def analyze_intent(intent_hash)
    return unless intent_hash[:intent] && intent_hash[:identity]

    mismatched_role = !MissionAnchorStore.roles.include?(intent_hash[:identity])
    spiral_risk = intent_hash[:flags]&.include?("conflict_detected") || intent_hash[:emotion] == "overwhelmed"

    if mismatched_role || spiral_risk
      log_drift(intent_hash)
      suggest_correction(intent_hash)
      route_for_review(intent_hash)
    end
  end

  def recent_drift_patterns
    read_log.reverse.first(MAX_HISTORY)
  end

  def log_drift(intent_hash)
    intent_hash[:drift_detected_at] = Time.now.utc.iso8601
    File.open(DRIFT_LOG, "a") { |f| f.puts(intent_hash.to_json) }
  rescue => e
    puts "[MissionDriftDetector] Logging error: #{e.message}"
  end

  def suggest_correction(intent_hash)
    TrainingSystem.queue_reflection(
      topic: "Drift Detected",
      context: intent_hash[:intent],
      identity: intent_hash[:identity],
      emotion: intent_hash[:emotion]
    )
  end

  def route_for_review(intent_hash)
    GuardianProtocol.flag_violation!(
      source: :mission_drift_detector,
      signature: intent_hash,
      result: { correction: true, reason: "drift_detected" }
    )
  end

  private

  def read_log
    return [] unless File.exist?(DRIFT_LOG)
    File.readlines(DRIFT_LOG).map { |line| JSON.parse(line) }
  rescue => e
    puts "[MissionDriftDetector] Read error: #{e.message}"
    []
  end
end
