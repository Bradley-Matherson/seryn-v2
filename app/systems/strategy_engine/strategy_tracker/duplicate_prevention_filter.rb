# 📁 /seryn/strategy_engine/strategy_tracker/duplicate_prevention_filter.rb

require_relative 'strategy_registry'
require_relative '../../../response_engine'
require_relative '../../../training_system'
require_relative '../../../strategy_engine/strategy_tracker/strategy_tracker'

module DuplicatePreventionFilter
  DUPLICATE_THRESHOLD = 0.82

  class << self
    def detect(incoming_strategy)
      existing_strategies = StrategyRegistry.all

      best_match = existing_strategies
        .map { |existing| [existing, similarity_score(existing, incoming_strategy)] }
        .select { |_, score| score >= DUPLICATE_THRESHOLD }
        .max_by { |_, score| score }

      if best_match
        existing, score = best_match
        handle_duplicate(existing, incoming_strategy, score)
        return {
          is_duplicate: true,
          existing_strategy_id: existing[:id],
          similarity_score: score.round(2),
          recommendation: "Evolve existing or restart it"
        }
      end

      { is_duplicate: false }
    end

    def similarity_score(existing, incoming)
      score = 0.0

      score += 0.3 if existing[:goal_category] == incoming[:goal_category]
      score += 0.2 if (existing[:tags] & incoming[:tags]).any?
      score += 0.1 if existing[:strategy_class] == incoming[:strategy_class]
      score += 0.1 if phase_name_match?(existing, incoming)
      score += 0.2 if fuzzy_task_match(existing, incoming)
      score += 0.1 if recent_failure_match?(existing, incoming)

      [score, 1.0].min
    end

    def phase_name_match?(existing, incoming)
      existing_phases = extract_phase_names(existing)
      incoming_phases = extract_phase_names(incoming)
      (existing_phases & incoming_phases).any?
    end

    def fuzzy_task_match(existing, incoming)
      e_tasks = extract_task_signatures(existing)
      i_tasks = extract_task_signatures(incoming)
      (e_tasks & i_tasks).size.to_f / [e_tasks.size, i_tasks.size].max.to_f > 0.5
    end

    def recent_failure_match?(existing, incoming)
      existing[:status] == :failed &&
        existing[:goal_category] == incoming[:goal_category]
    end

    def extract_phase_names(strategy)
      (strategy[:phases] || []).map { |p| p[:name].downcase.strip rescue nil }.compact
    end

    def extract_task_signatures(strategy)
      (strategy[:phases] || []).flat_map do |p|
        (p[:tasks] || []).map { |t| t.downcase.gsub(/[^a-z]/, '')[0..8] rescue nil }
      end.compact.uniq
    end

    def handle_duplicate(existing, incoming, score)
      TrainingSystem.log_pattern(:duplicate_strategy_detected, existing[:id])
      ResponseEngine.deliver_soft_prompt(<<~MSG.strip)
        ⚠️ You already have a similar strategy active or archived:
        **#{existing[:title]}** (match score: #{score.round(2)})

        Would you like to:
        - ✅ Reactivate it
        - 🔁 Evolve the original
        - 🛑 Cancel the new one
      MSG
    end
  end
end
