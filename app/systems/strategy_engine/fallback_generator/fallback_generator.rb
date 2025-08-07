# 📁 core/strategy/fallback_generator/fallback_generator.rb

require_relative 'primary_block_detector'
require_relative 'fallback_pattern_selector'
require_relative 'fallback_builder'
require_relative 'resumable_strategy_tagger'
require_relative 'guardian_escalation_hook'

module FallbackGenerator
  class << self
    def generate(original_strategy, constraints, alignment_check)
      block_status = PrimaryBlockDetector.evaluate(original_strategy, constraints, alignment_check)

      return { fallback_required: false } unless block_status[:fallback_required]

      fallback_template = FallbackPatternSelector.select(block_status[:reason], original_strategy)
      fallback_plan     = FallbackBuilder.build(fallback_template)
      ResumableStrategyTagger.store(original_strategy, fallback_plan[:resume_condition])

      if GuardianEscalationHook.trigger?(constraints, fallback_template)
        return GuardianEscalationHook.escalate(original_strategy)
      end

      {
        fallback_strategy: fallback_plan,
        original_strategy: original_strategy[:description],
        resumable: true,
        resume_condition: fallback_plan[:resume_condition]
      }
    end
  end
end
