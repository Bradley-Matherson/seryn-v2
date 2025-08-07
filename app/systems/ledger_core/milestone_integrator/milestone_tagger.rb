# 📘 MilestoneTagger — Auto-Tags Today's Tasks with Relevant Milestone IDs
# Subcomponent of LedgerCore::MilestoneIntegrator

require_relative '../../../ledger_core/daily_task_decomposer/daily_task_decomposer'
require_relative '../../../memory/memory_logger'

module LedgerCore
  module MilestoneIntegrator
    module MilestoneTagger
      class << self
        def tag_today_tasks(milestones)
          task_data = LedgerCore::DailyTaskDecomposer::Controller.run
          tasks = task_data[:today_tasks]

          tagged = tasks.map do |task|
            matched = match_to_milestone(task[:title], milestones)
            {
              title: task[:title],
              milestone: matched&.dig(:id),
              priority: task[:priority],
              role: task[:role_tag]
            }
          end

          MemoryLogger.append(:task_milestone_tags, tagged)
          tagged
        end

        private

        def match_to_milestone(task_title, milestones)
          task_words = task_title.downcase.split

          milestones.find do |m|
            milestone_words = m[:id].to_s.downcase.split("_") +
                              m[:target].to_s.downcase.split
            (task_words & milestone_words).any?
          end
        end
      end
    end
  end
end
