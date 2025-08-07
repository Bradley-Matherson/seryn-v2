# 📘 MilestoneReminderEngine — Prompts User When Milestones Are Neglected or Nearing Completion
# Subcomponent of LedgerCore::MilestoneIntegrator

require_relative '../../../response_engine/response_engine'
require_relative '../../task_memory_bank/controller'

module LedgerCore
  module MilestoneIntegrator
    module MilestoneReminderEngine
      class << self
        def generate(milestones)
          milestones.filter_map do |m|
            next unless needs_attention?(m)

            prompt = build_prompt(m)
            log_to_memory(m, prompt)
            ResponseEngine::Controller.inject_reflection(prompt)

            { id: m[:id], prompt: prompt, priority: attention_level(m) }
          end
        end

        private

        def needs_attention?(m)
          return true if m[:trajectory] == :stalled
          return true if m[:last_updated] >= 5
          return true if m[:progress].to_f >= 90
          return true if m[:last_progress_delta] && m[:last_progress_delta] < -3
          false
        end

        def build_prompt(m)
          id_label = format_title(m[:id])

          return "You're almost at the finish line for your #{id_label} milestone! Need help wrapping it up?" if m[:progress].to_f >= 90
          return "Your #{id_label} goal hasn’t moved in a while. Want to revisit it?" if m[:last_updated] >= 5
          return "Progress on #{id_label} has dropped. Want to reassess or swap the approach?" if m[:last_progress_delta] && m[:last_progress_delta] < -3

          "Let's revisit your #{id_label} milestone. It’s showing signs of slowdown."
        end

        def format_title(id)
          id.to_s.gsub("_", " ").capitalize
        end

        def attention_level(m)
          return :critical if m[:trajectory] == :stalled || m[:last_progress_delta].to_f < -4
          return :high if m[:last_updated] >= 5
          return :medium if m[:progress].to_f >= 90
          :low
        end

        def log_to_memory(m, prompt)
          LedgerCore::TaskMemoryBank::Controller.log_milestone_prompt(
            milestone_id: m[:id],
            message: prompt,
            flagged_at: Date.today.to_s
          )
        end
      end
    end
  end
end
