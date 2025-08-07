# 📁 seryn/systems/output_control/render_manager/data_stitcher.rb

require_relative "../../../ledger_core/ledger_core"
require_relative "../../../context_stack/context_stack"
require_relative "../../../strategy_engine/strategy_engine"
require_relative "../../../training_system/training_system"
require_relative "../../../response_engine/response_engine"

module DataStitcher
  class << self
    def build_context(render_type)
      {
        render_type: render_type,
        identity_role: LedgerCore::Identity.active,
        tasks: LedgerCore::Tasks.today_list,
        streak: LedgerCore::Streak.current_count,
        mood: ContextStack::Emotion.current_state,
        energy: ContextStack::Energy.current_level,
        burnout: ContextStack::Burnout.status,
        mode: ContextStack::Mode.active,
        strategy_focus: StrategyEngine::Phases.active,
        strategy_steps: StrategyEngine::Phases.current_steps,
        reflection_prompt: TrainingSystem::Prompts.current_reflection,
        phrasing: ResponseEngine::Tone.current_summary_phrase,
        date: Time.now.strftime("%A, %B %d"),
        tone: ContextStack::Tone.current_voice_tone
      }
    rescue => e
      puts "⚠️ [DataStitcher] Failed to build context: #{e.message}"
      {}
    end
  end
end
