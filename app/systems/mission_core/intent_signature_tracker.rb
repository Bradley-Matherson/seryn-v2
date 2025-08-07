# core/intent_signature_tracker.rb

require_relative "mission_anchor_store"
require_relative "guardian_protocol"
require_relative "mission_drift_detector"

module IntentSignatureTracker
  extend self

  LOG_FILE = "data/intent_log.txt"

  def log_intent(intent_hash)
    intent_hash[:timestamp] ||= Time.now.utc.iso8601
    write_log(intent_hash)
    MissionDriftDetector.analyze_intent(intent_hash)
    intent_hash
  end

  def is_who_you_want_to_be?(intent_hash)
    desired_roles = MissionAnchorStore.roles
    intent_role = intent_hash[:identity]
    desired_roles.include?(intent_role)
  end

  def check_for_spiral?(intent_hash)
    past_flags = read_log.reverse.first(50).select do |entry|
      entry["intent"] == intent_hash[:intent] &&
      entry["flags"]&.include?("conflict_detected")
    end
    past_flags.size >= 2
  end

  def pattern_match(intent_hash)
    past_entries = read_log.reverse.first(100)
    similar = past_entries.select { |e| e["intent"] == intent_hash[:intent] }
    similar.map { |e| e["flags"] }.flatten.compact.uniq
  end

  private

  def write_log(data)
    File.open(LOG_FILE, "a") { |f| f.puts(data.to_json) }
  rescue => e
    puts "[IntentSignatureTracker] Logging error: #{e.message}"
  end

  def read_log
    return [] unless File.exist?(LOG_FILE)
    File.readlines(LOG_FILE).map { |line| JSON.parse(line) }
  rescue => e
    puts "[IntentSignatureTracker] Read error: #{e.message}"
    []
  end
end
