# 📁 seryn/systems/output_control/output_formatter/placeholder_resolver.rb

require_relative "../../../context_stack/context_stack"
require_relative "../../../ledger_core/ledger_core"
require_relative "../../../strategy_engine/strategy_engine"
require_relative "../../../training_system/training_system"

module OutputFormatter
  module PlaceholderResolver
    class << self
      def resolve(content)
        context = build_context
        ERB.new(content, trim_mode: "-").result_with_hash(context)
      end

      private

      def build_context
        {
          identity_role: ContextStack::Identity.current_role,
          emotion_state: ContextStack::Emotion.current_state,
          focus: StrategyEngine::Focus.current_focus,
          tasks: LedgerCore::Tasks.today_list,
          reflection: TrainingSystem::Prompts.current_reflection,
          streak_count: LedgerCore::Streak.current_count,
          voice_mode: ContextStack::Tone.current_voice,
          date: Time.now.strftime("%Y-%m-%d"),
          goal_phase: StrategyEngine::Phases.active,
          momentum_notes: StrategyEngine::Momentum.summary,
          steps: StrategyEngine::Phases.current_steps,
          drift_detected: ContextStack::Drift.detected?
        }
      rescue => e
        puts "[PlaceholderResolver] Context fetch failed: #{e.message}"
        {}
      end
    end
  end
end
