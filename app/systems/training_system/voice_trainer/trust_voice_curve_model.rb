# frozen_string_literal: true

# 📈 TrustVoiceCurveModel
# Purpose:
# Blends current trust score and emotional bandwidth to determine:
# - How direct Seryn can be
# - When to soften or stay silent
# - When to use mirror-mode over advice
# Influences real-time tone modulation.

require_relative '../../guardian_protocol'
require_relative '../../training_system/memory_pattern_miner/emotion_trajectory_mapper'

module TrainingSystem
  module VoiceTrainer
    module TrustVoiceCurveModel
      def self.calculate_trust_window(context)
        trust_score = GuardianProtocol.current_trust_score rescue 0.75
        emotional_bandwidth = current_momentum_state

        # Final weight favors caution during instability
        if emotional_bandwidth == :unstable
          adjusted = (trust_score * 0.85).round(2)
        elsif emotional_bandwidth == :rising
          adjusted = (trust_score * 1.05).round(2)
        else
          adjusted = trust_score.round(2)
        end

        adjusted.clamp(0.0, 1.0)
      end

      def self.current_momentum_state
        arc = MemoryPatternMiner::EmotionTrajectoryMapper.compile_weekly_arc rescue {}
        momentum = arc[:momentum] || :flat

        case momentum
        when :rising then :rising
        when :declining then :unstable
        else :neutral
        end
      end

      def self.force_override(style, reason)
        GuardianProtocol.log_adjustment("Manual tone override to '#{style}' due to: #{reason}")
        { override_accepted: true, applied_style: style, reason: reason }
      end
    end
  end
end
