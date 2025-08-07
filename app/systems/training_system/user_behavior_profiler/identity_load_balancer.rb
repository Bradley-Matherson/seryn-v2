# frozen_string_literal: true

# ⚖️ IdentityLoadBalancer
# Purpose:
# Tracks how much time and task energy is being spent in each identity role (e.g., Father, Builder, Strategist).
# Detects imbalance and provides data for rebalancing tone, task types, and strategy themes.

require_relative '../../memory'
require_relative '../../ledger_core'

module TrainingSystem
  module UserBehaviorProfiler
    module IdentityLoadBalancer
      def self.analyze_identity_distribution
        memory_entries = Memory.fetch_recent_entries(7)
        task_logs = LedgerCore.fetch_recent_task_logs rescue []

        role_counts = Hash.new(0)

        (memory_entries + task_logs).each do |entry|
          role = entry[:identity_mode] || entry[:active_identity]
          next unless role
          role_counts[role.to_sym] += 1
        end

        total = role_counts.values.sum.to_f
        return {} if total.zero?

        # Normalize to percentage
        role_distribution = role_counts.transform_values { |v| (v / total).round(2) }

        role_distribution
      end

      def self.suggest_identity_rebalance(identity_distribution)
        return nil unless identity_distribution.is_a?(Hash) && !identity_distribution.empty?

        lowest_role = identity_distribution.min_by { |_, v| v }
        if lowest_role && lowest_role[1] < 0.15
          {
            suggestion: "You've been heavily favoring one identity mode. Want to rebalance toward #{lowest_role[0].to_s.capitalize}?",
            underused_role: lowest_role[0]
          }
        else
          nil
        end
      end
    end
  end
end
