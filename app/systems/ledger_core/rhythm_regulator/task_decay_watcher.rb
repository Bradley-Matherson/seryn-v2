# 📘 TaskDecayWatcher — Monitors Task Avoidance and Suggests Reassessment
# Subcomponent of LedgerCore::RhythmRegulator

require_relative '../../../training_system/training_system'
require_relative '../../../response_engine/response_engine'
require_relative '../../../guardian_protocol/guardian_protocol'
require_relative '../../../memory/memory_logger'
require_relative '../../task_memory_bank/controller'

module LedgerCore
  module RhythmRegulator
    module TaskDecayWatcher
      class << self
        def scan
          decaying_tasks.each do |task|
            GuardianProtocol::Controller.flag(:task_decay, task)
            ResponseEngine::Controller.inject_reflection(decay_prompt(task))
            MemoryLogger.append(:task_decay_alerts, { task: task, date: Date.today })
            log_to_memory(task)
          end
        end

        private

        def decaying_tasks
          TrainingSystem::Controller.skipped_tasks
            .select { |task| task[:skip_count] >= 3 }
        end

        def decay_prompt(task)
          "The task \"#{task[:title]}\" has been deferred #{task[:skip_count]} times. Want to revise it, swap it, or remove it?"
        end

        def log_to_memory(task)
          LedgerCore::TaskMemoryBank::Controller.log_decay_event(
            title: task[:title],
            skip_count: task[:skip_count],
            priority: task[:priority],
            role_tag: task[:role_tag],
            date: Date.today.to_s
          )
        end
      end
    end
  end
end
