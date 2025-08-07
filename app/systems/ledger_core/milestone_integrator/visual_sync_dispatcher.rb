# 📘 VisualSyncDispatcher — Syncs Milestone Data to Visual Dashboards and Ledger Outputs
# Subcomponent of LedgerCore::MilestoneIntegrator

require_relative '../../../response_engine/response_engine'
require_relative '../../../memory/memory_logger'

module LedgerCore
  module MilestoneIntegrator
    module VisualSyncDispatcher
      class << self
        def sync(milestones)
          visuals = milestones.map do |m|
            {
              id: m[:id],
              label: format_label(m[:id]),
              progress: "#{m[:progress]}%",
              status: m[:trajectory],
              blocked: m[:blocked],
              due: m[:due_date],
              color: determine_color(m),
              priority: assign_priority(m)
            }
          end

          MemoryLogger.append(:milestone_visuals, visuals)
          ResponseEngine::Controller.inject_milestone_visuals(visuals)

          visuals
        end

        private

        def format_label(id)
          id.to_s.gsub("_", " ").capitalize
        end

        def determine_color(m)
          return "gray" if m[:blocked]
          case m[:trajectory]
          when :on_track   then "green"
          when :improving  then "blue"
          when :slow_start then "lightgray"
          when :stalled    then "orange"
          when :blocked    then "red"
          else "gray"
          end
        end

        def assign_priority(m)
          return :critical if m[:trajectory] == :stalled
          return :high     if m[:progress].to_f >= 90
          return :medium   if m[:progress].to_f >= 40
          :low
        end
      end
    end
  end
end
