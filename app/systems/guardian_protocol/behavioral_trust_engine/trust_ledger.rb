# seryn/guardian_protocol/behavioral_trust_engine/trust_ledger.rb

require 'json'
require 'fileutils'

module TrustLedger
  LOG_DIR = 'logs/guardian/trust_ledger'
  SCORE_FILE = File.join(LOG_DIR, 'trust_scores.json')

  @scores = Hash.new(0.85) # Default starting trust score

  def self.log_entry(system:, delta:, context:)
    FileUtils.mkdir_p(LOG_DIR)

    @scores[system] ||= 0.85
    @scores[system] += delta
    @scores[system] = [[@scores[system], 1.0].min, 0.0].max

    date = Time.now.strftime('%Y-%m-%d')
    path = File.join(LOG_DIR, "#{date}.log")

    log_data = {
      timestamp: Time.now,
      system: system,
      delta: delta,
      new_score: @scores[system].round(3),
      context: {
        success: context[:success],
        violations: context[:violations],
        override: context[:override_attempted],
        user_feedback: context[:user_feedback]
      }
    }

    File.open(path, 'a') { |f| f.puts(JSON.pretty_generate(log_data)) }
    persist_scores
  end

  def self.current_scores
    load_scores unless File.exist?(SCORE_FILE)
    @scores
  end

  def self.persist_scores
    File.open(SCORE_FILE, 'w') do |f|
      f.puts(JSON.pretty_generate(@scores.transform_values { |v| v.round(3) }))
    end
  end

  def self.load_scores
    if File.exist?(SCORE_FILE)
      raw = JSON.parse(File.read(SCORE_FILE))
      @scores = raw.transform_keys(&:to_sym).transform_values(&:to_f)
    end
  end
end
