# 📁 core/strategy/fallback_generator/primary_block_detector.rb

module PrimaryBlockDetector
  class << self
    def evaluate(strategy, constraints, alignment)
      fallback_required = false
      reason = nil

      if blocked_by_constraints?(constraints)
        fallback_required = true
        reason = analyze_fail_cause(constraints)
      elsif blocked_by_guardian?(alignment)
        fallback_required = true
        reason = :alignment_violation
      end

      {
        blocked: fallback_required,
        reason: reason,
        fallback_required: fallback_required
      }
    end

    def blocked_by_constraints?(c)
      c[:available_hours] < 3 || c[:money_buffer] < 50 || c[:energy] == :low || c[:clash]
    end

    def blocked_by_guardian?(alignment)
      alignment[:approved] == false || alignment[:warning] == true
    end

    def analyze_fail_cause(c)
      return :low_time if c[:available_hours] < 3
      return :low_money if c[:money_buffer] < 50
      return :low_energy if c[:energy] == :low
      return :conflicting_commitment if c[:clash]
      :unknown
    end
  end
end
