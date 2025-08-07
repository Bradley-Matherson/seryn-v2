# frozen_string_literal: true

# 🧬 BehavioralArchetypeUpdater
# Purpose:
# Evolves Seryn’s understanding of your growth phase and identity balance.
# This archetype is used for strategy pacing, tone modulation, and expectation calibration.

require 'json'
require 'fileutils'

module TrainingSystem
  module UserBehaviorProfiler
    module BehavioralArchetypeUpdater
      ARCHETYPE_FILE = "data/current_user_archetype.json"

      def self.update_profile_archetype
        data = analyze_recent_behavior
        archetype = classify_archetype(data)
        save_archetype(archetype)
        archetype
      end

      def self.analyze_recent_behavior
        logs = File.exist?("data/user_behavior_profile.json") ? JSON.parse(File.read("data/user_behavior_profile.json"), symbolize_names: true) : {}

        {
          task_volume: logs.dig(:momentum_cycle, :burnout_after)&.to_s&.match(/\d+/)&.to_s.to_i || 3,
          resistance: logs[:resistance_patterns]&.size || 0,
          identity_spread: logs[:identity_load] || {}
        }
      end

      def self.classify_archetype(data)
        if data[:resistance] >= 3
          :overloaded_builder
        elsif data[:task_volume] <= 2
          :fragile_rhythm
        elsif dominant_identity(data[:identity_spread]) == :strategist
          :focused_strategist
        elsif dominant_identity(data[:identity_spread]) == :builder
          :momentum_builder
        else
          :balanced_phase
        end
      end

      def self.dominant_identity(spread)
        spread.max_by { |_, v| v }&.first
      end

      def self.save_archetype(archetype)
        FileUtils.mkdir_p(File.dirname(ARCHETYPE_FILE))
        File.write(ARCHETYPE_FILE, JSON.pretty_generate({ current_archetype: archetype, updated_at: Time.now }))
      end

      def self.get_current_archetype
        return nil unless File.exist?(ARCHETYPE_FILE)
        JSON.parse(File.read(ARCHETYPE_FILE), symbolize_names: true)[:current_archetype]
      end
    end
  end
end
