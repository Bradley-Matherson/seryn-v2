# frozen_string_literal: true

# 📅 DailyReflectionScanner
# Purpose:
# At the end of each active day or cycle, this module scans key system signals
# and assembles a summary of Seryn's tone performance, emotional trajectory,
# trust deltas, identity role usage, and completion rhythm.

require_relative '../../training_system/memory_pattern_miner/emotion_trajectory_mapper'
require_relative '../../guardian_protocol'
require_relative '../../context_stack'
require_relative '../../voice_trainer/tone_feedback_logger'
require_relative '../../ledger_core'

module TrainingSystem
  module SelfCalibrationLoop
    module DailyReflectionScanner
      def self.compile_system_status
        emotion_trend = fetch_emotional_trend
        trust_change = fetch_trust_delta
        tone_effectiveness = tone_was_helpful?
        identity_distribution = ContextStack.recent_identity_balance rescue {}
        task_completion_stats = LedgerCore.daily_completion_score rescue {}

        {
          spiral_detected: emotion_trend[:spiral_events].to_i > 0,
          emotional_trend: emotion_trend[:momentum],
          trust_change: trust_change,
          tone_useful: tone_effectiveness,
          identity_balance: identity_distribution,
          task_completion_rate: task_completion_stats[:completion_rate],
          anchor_used: ContextStack.last_pillar_reference || :unknown
        }
      end

      def self.fetch_emotional_trend
        MemoryPatternMiner::EmotionTrajectoryMapper.compile_weekly_arc rescue {}
      end

      def self.fetch_trust_delta
        GuardianProtocol.trust_change_today rescue 0.0
      end

      def self.tone_was_helpful?
        last_log = VoiceTrainer::ToneFeedbackLogger.load_log.last
        return false unless last_log
        %i[high_reflection neutral_effect].include?(last_log[:outcome])
      end
    end
  end
end
