# frozen_string_literal: true

# 🧭 MissionDriftDetector
# Purpose:
# Compares current behavior (time use, tone shifts, system usage) against active roles,
# goals, and purpose pillars to detect passive misalignment or role neglect.

require_relative '../../mission_core'
require_relative '../../memory'
require_relative '../../ledger_core'

module TrainingSystem
  module MemoryPatternMiner
    module MissionDriftDetector
      def self.analyze_alignment
        mission_snapshot = MissionCore.current_pillars rescue {}
        recent_logs = Memory.fetch_recent_entries(7)
        task_logs = LedgerCore.fetch_recent_task_logs rescue []

        role_focus = count_identity_mentions(recent_logs + task_logs)
        goal_focus = track_goal_alignment(task_logs)
        pillar_presence = match_pillars_in_logs(recent_logs)

        drift_flags = detect_drift(role_focus, goal_focus, pillar_presence)

        {
          roles_active: role_focus,
          goal_focus: goal_focus,
          matched_pillars: pillar_presence,
          drift_warning: drift_flags.any?,
          drift_flags: drift_flags
        }
      end

      def self.count_identity_mentions(logs)
        counts = Hash.new(0)
        logs.each do |entry|
          mode = entry[:identity_mode] || entry[:active_identity]
          counts[mode] += 1 if mode
        end
        counts.sort_by { |_, v| -v }.to_h
      end

      def self.track_goal_alignment(tasks)
        alignment_counts = Hash.new(0)
        tasks.each do |task|
          goal = task[:linked_goal]
          alignment_counts[goal] += 1 if goal
        end
        alignment_counts.sort_by { |_, v| -v }.to_h
      end

      def self.match_pillars_in_logs(logs)
        pillars = MissionCore.purpose_pillars rescue []
        present = []

        logs.each do |log|
          content = log[:content].to_s.downcase
          pillars.each do |pillar|
            present << pillar if content.include?(pillar.to_s)
          end
        end

        present.uniq
      end

      def self.detect_drift(roles, goals, pillars)
        flags = []

        if roles[:builder].to_i > 3 && roles[:father].to_i == 0
          flags << :role_neglect_father
        end

        if goals.values.sum == 0
          flags << :goal_drift
        end

        if pillars.size < 2
          flags << :pillar_drift
        end

        flags
      end
    end
  end
end
