# frozen_string_literal: true

# 🧠 TrainingRecallUpdater (v2)
# Purpose:
# Internalizes each reflection cycle into Seryn’s adaptive architecture.
# Includes reinforcement mapping, memory pruning flags, mission-aware weighting,
# pre-training reflex buffer, and hooks for future self-upgrade logic.

require 'json'
require 'fileutils'

module TrainingSystem
  module SelfCalibrationLoop
    module TrainingRecallUpdater
      MEMORY_PATH = "data/self_tuning_weights.json"
      CANDIDATE_TUNING_PATH = "data/candidate_tuning.json"

      def self.apply_learnings(reflection, adjustments, anomalies)
        memory = load_weights

        update_tone_preferences(memory, adjustments)
        update_strategy_pacing(memory, adjustments)
        update_identity_weights(memory, reflection)
        log_phrase_avoidance(memory, reflection, anomalies)
        weight_behavior_with_mission(reflection, memory)
        emit_candidate_tuning(adjustments, reflection)
        check_for_memory_pruning(reflection, memory)
        trigger_rewrite_hooks(adjustments, reflection)

        File.write(MEMORY_PATH, JSON.pretty_generate(memory))
        memory
      end

      # == Load or Initialize ==
      def self.load_weights
        File.exist?(MEMORY_PATH) ? JSON.parse(File.read(MEMORY_PATH), symbolize_names: true) : default_weights
      end

      def self.default_weights
        {
          tone_preferences: {},
          phrase_avoidance: [],
          strategy_pacing: { default_limit: 3 },
          identity_weights: {},
          reinforcement_history: []
        }
      end

      # == Updates ==
      def self.update_tone_preferences(memory, adjustments)
        tone_shift = adjustments[:actions].find { |a| a[:action] == :tone_shift }
        return unless tone_shift

        memory[:tone_preferences][:last_shift] = {
          from: tone_shift[:from],
          to: tone_shift[:to],
          timestamp: Time.now
        }
      end

      def self.update_strategy_pacing(memory, adjustments)
        pacing = adjustments[:actions].find { |a| a[:action] == :slow_task_pacing }
        memory[:strategy_pacing][:default_limit] = pacing[:new_limit] if pacing
      end

      def self.update_identity_weights(memory, reflection)
        (reflection[:identity_balance] || {}).each do |role, count|
          memory[:identity_weights][role] ||= 0
          memory[:identity_weights][role] += count
        end
      end

      def self.log_phrase_avoidance(memory, reflection, anomalies)
        return unless reflection[:spiral_detected]
        flagged = anomalies.select { |a| a[:type] == :tone_misuse }
        flagged.each do |anomaly|
          phrase = anomaly[:context].to_s
          memory[:phrase_avoidance] << phrase unless memory[:phrase_avoidance].include?(phrase)
        end
      end

      def self.weight_behavior_with_mission(reflection, memory)
        identity = reflection[:identity_balance]&.max_by { |_, v| v }&.first
        anchor = reflection[:anchor_used] || :unknown

        penalty = if identity == :builder && anchor == :family
          -0.3
        elsif identity == :father && anchor == :legacy
          +0.2
        else
          0.0
        end

        memory[:reinforcement_history] << {
          timestamp: Time.now,
          identity: identity,
          anchor: anchor,
          trust_change: reflection[:trust_change],
          mission_weight: penalty
        }
      end

      def self.emit_candidate_tuning(adjustments, reflection)
        change = {
          type: :voice_pacing,
          new_value: "slower, 12% pause bump",
          reason: "calmed spiral",
          applied: false,
          approved_by: nil
        }

        if reflection[:spiral_detected] && adjustments[:actions].any? { |a| a[:action] == :tone_shift }
          File.write(CANDIDATE_TUNING_PATH, JSON.pretty_generate(change))
        end
      end

      def self.check_for_memory_pruning(reflection, memory)
        if (reflection[:identity_balance] || {}).values.all? { |v| v < 1 }
          memory[:prune_signal] = {
            triggered: true,
            reason: "inactive identity modes for 7+ days",
            timestamp: Time.now
          }
        end
      end

      def self.trigger_rewrite_hooks(adjustments, reflection)
        if adjustments[:actions].any? { |a| a[:action] == :pause_strategy_retry } &&
           reflection[:trust_change] < -0.03
          return unless defined?(SelfRewriteEngine) && !GuardianProtocol.blocked?(:self_modification)

          SelfRewriteEngine.queue_patch(
            pattern_id: :strategy_template_current,
            reason: "Pattern failed under trust loss & spiral"
          )
        end
      end
    end
  end
end
