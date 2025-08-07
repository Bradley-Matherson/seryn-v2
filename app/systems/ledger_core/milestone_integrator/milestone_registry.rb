# 📘 MilestoneRegistry — Stores and Updates All Active Milestones
# Subcomponent of LedgerCore::MilestoneIntegrator

require_relative '../../../strategy_engine/strategy_engine'
require_relative '../../../mission_core/mission_core'

module LedgerCore
  module MilestoneIntegrator
    module MilestoneRegistry
      @milestones = []

      class << self
        def load_all
          @milestones = (
            from_strategy_engine +
            from_mission_core +
            from_user_prompts
          ).uniq { |m| m[:id] }

          enrich_milestones(@milestones)
        end

        def from_strategy_engine
          StrategyEngine::Controller.milestones || []
        end

        def from_mission_core
          MissionCore::Controller.trajectory_goals || []
        end

        def from_user_prompts
          # Placeholder until interactive Ledger inputs are live
          [
            {
              id: :fix_sleep_cycle,
              type: :health,
              target: "7hr avg sleep by end of month",
              due_date: "2025-08-31",
              status: :in_progress
            }
          ]
        end

        def enrich_milestones(milestones)
          milestones.each do |m|
            m[:current]  ||= default_current_for(m)
            m[:progress] = calculate_progress(m)
            m[:blocked]  = false if m[:blocked].nil?
          end
        end

        def default_current_for(milestone)
          case milestone[:type]
          when :financial then "$0"
          when :health     then "0%"
          else nil
          end
        end

        def calculate_progress(milestone)
          return 0.0 unless milestone[:target] && milestone[:current]

          begin
            t = milestone[:target].to_s.gsub(/[^\d\.]/, '').to_f
            c = milestone[:current].to_s.gsub(/[^\d\.]/, '').to_f
            return 0.0 if t.zero?
            ((c / t) * 100).round(1)
          rescue
            0.0
          end
        end

        def list
          @milestones
        end
      end
    end
  end
end
