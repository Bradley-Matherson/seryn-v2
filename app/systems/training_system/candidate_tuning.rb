# frozen_string_literal: true

# 🧪 CandidateTuning
# Purpose:
# Manages the staging zone for pre-applied tuning decisions.
# These are proposed adjustments to tone, pacing, phrasing, or strategy formatting
# that require approval (via user or GuardianProtocol) before activation.

require 'json'
require 'fileutils'

module TrainingSystem
  module CandidateTuning
    TUNING_PATH = "data/candidate_tuning.json"

    def self.log_tuning_proposal(type:, new_value:, reason:)
      entry = {
        type: type,
        new_value: new_value,
        reason: reason,
        applied: false,
        approved_by: nil,
        timestamp: Time.now
      }

      FileUtils.mkdir_p(File.dirname(TUNING_PATH))
      File.write(TUNING_PATH, JSON.pretty_generate(entry))
    end

    def self.pending?
      File.exist?(TUNING_PATH) && !load[:applied]
    end

    def self.load
      return {} unless File.exist?(TUNING_PATH)
      JSON.parse(File.read(TUNING_PATH), symbolize_names: true)
    end

    def self.approve(approver = :user)
      tuning = load
      return unless tuning[:applied] == false

      tuning[:applied] = true
      tuning[:approved_by] = approver
      File.write(TUNING_PATH, JSON.pretty_generate(tuning))

      apply_change(tuning)
    end

    def self.reject
      File.delete(TUNING_PATH) if File.exist?(TUNING_PATH)
    end

    def self.apply_change(tuning)
      # Trigger based on type
      case tuning[:type].to_sym
      when :voice_pacing
        VoiceTrainer::TrustVoiceCurveModel.set_default_pacing(tuning[:new_value]) if defined?(VoiceTrainer::TrustVoiceCurveModel)
      when :tone_template
        ResponseEngine.modify_template_variant(tuning[:new_value]) if defined?(ResponseEngine)
      else
        puts "[CandidateTuning] Unknown tuning type: #{tuning[:type]}"
      end
    end
  end
end
