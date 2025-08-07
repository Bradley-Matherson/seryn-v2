# 📘 MilestoneIntegrator — Tracks Long-Term Goal Progress & Readiness
# Subsystem of LedgerCore

require_relative 'milestone_registry'
require_relative 'trajectory_analyzer'
require_relative 'milestone_reminder_engine'
require_relative 'visual_sync_dispatcher'
require_relative 'milestone_tagger'
require_relative '../task_memory_bank/controller'

module LedgerCore
  module MilestoneIntegrator
    class Controller
      class << self
        def run
          milestones = MilestoneRegistry.load_all
          updates    = TrajectoryAnalyzer.evaluate(milestones)
          reminders  = MilestoneReminderEngine.generate(updates)
          visuals    = VisualSyncDispatcher.sync(updates)
          tagged     = MilestoneTagger.tag_today_tasks(updates)

          # Log milestone patterns into TaskMemoryBank
          TaskMemoryBank::Controller.log_milestone_activity(tagged)

          {
            milestones: enrich_output(updates),
            tagged_tasks: tagged,
            reminders: reminders,
            visuals: visuals
          }
        end

        private

        def enrich_output(milestones)
          milestones.map do |m|
            {
              id: m[:id],
              target: m[:target],
              current: m[:current],
              trajectory: m[:trajectory],
              blocked: m[:blocked],
              progress: m[:progress],
              resume_condition: m[:resume_condition]
            }.compact
          end
        end
      end
    end
  end
end
