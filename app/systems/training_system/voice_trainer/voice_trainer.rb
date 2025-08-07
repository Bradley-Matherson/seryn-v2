# frozen_string_literal: true

# 🎙️ VoiceTrainer — Subsystem Controller
# Purpose:
# Orchestrates tone optimization and adaptive phrasing based on identity role,
# trust level, emotional state, and prompt effectiveness.

require_relative './tone_feedback_logger'
require_relative './identity_speech_matcher'
require_relative './phrase_effect_evaluator'
require_relative './trust_voice_curve_model'
require_relative './response_remixer'

module TrainingSystem
  module VoiceTrainer
    def self.generate_tone_update(current_context)
      trust = TrustVoiceCurveModel.calculate_trust_window(current_context)
      identity_style = IdentitySpeechMatcher.map_identity_to_tone(current_context[:identity])
      phrasing_score = PhraseEffectEvaluator.score_last_prompt(current_context[:last_prompt])
      remix = ResponseRemixer.adapt_prompt(current_context[:last_prompt])

      update = {
        current_identity: current_context[:identity],
        trust_score: trust,
        last_prompt_style: phrasing_score[:style],
        next_style: identity_style,
        remix_variant: remix
      }

      ToneFeedbackLogger.log_feedback_event(update)
      update
    end

    def self.manual_override(new_style:, reason:)
      TrustVoiceCurveModel.force_override(new_style, reason)
    end
  end
end
