# 📁 /seryn/strategy_engine/constraint_analyzer/constraint_summary_builder.rb

require 'json'
require 'time'

module ConstraintSummaryBuilder
  LOG_PATH = 'logs/strategy/constraint_matrix_snapshots.log'

  class << self
    def build(time, money, energy, clash)
      score = calculate_trust_score(time, money, energy, clash)

      ready = score >= 0.75 && !clash[:conflict_detected] &&
              !time[:blocked] && !money[:blocked] && !energy[:blocked]

      result = {
        time_available: time[:time_available],
        energy: energy[:energy],
        mood_state: energy[:mood],
        money: money[:cash_available],
        readiness_phase: money[:readiness_phase],
        trust_score: score.round(2),
        competing_strategies: ContextStack[:active_strategy_count] || 0,
        conflict_detected: clash[:conflict_detected],
        ready: ready,
        warnings: (time[:warning] || []) +
                  (money[:warning] || []) +
                  (energy[:warning] || []) +
                  (clash[:warnings] || [])
      }

      log_matrix(result)
      result
    end

    def calculate_trust_score(time, money, energy, clash)
      score = 1.0
      score -= 0.25 if time[:blocked]
      score -= 0.25 if energy[:trust_state] == :fragile
      score -= 0.35 if energy[:trust_state] == :unstable
      score -= 0.25 if money[:readiness_phase] == :risky
      score -= 0.35 if money[:readiness_phase] == :blocked
      score -= 0.2  if clash[:conflict_detected]
      [score, 0.0].max
    end

    def log_matrix(result)
      File.open(LOG_PATH, 'a') do |f|
        f.puts "[#{Time.now.iso8601}] #{result.to_json}"
      end
    end
  end
end
