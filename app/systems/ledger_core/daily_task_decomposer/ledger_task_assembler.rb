# 📘 LedgerTaskAssembler — Finalizes and Routes Daily Task Set
# Subcomponent of LedgerCore::DailyTaskDecomposer

require_relative '../../../response_engine/response_engine'
require_relative '../../../training_system/training_system'
require_relative '../../../memory/memory_logger'
require_relative '../../../interpreter_system/context_stack'

module LedgerCore
  module DailyTaskDecomposer
    module LedgerTaskAssembler
      class << self
        def assemble(task_list)
          formatted = format_tasks(task_list)
          log_skipped_tasks
          log_swap_patterns(task_list)
          memory_tagging(task_list)

          ResponseEngine::Controller.inject_tasks(formatted)

          {
            today_tasks: task_list,
            formatted_tasks: formatted,
            energy: TrainingSystem::Controller.current_energy,
            momentum_level: TrainingSystem::Controller.momentum_streak,
            self_care: default_self_care,
            focus: detect_focus(task_list)
          }
        end

        private

        def format_tasks(tasks)
          tasks.map do |task|
            priority = task[:priority] || :unknown
            "#{task[:title]} (#{priority_symbol(priority)})"
          end
        end

        def priority_symbol(priority)
          case priority
          when :high   then "🟥 high"
          when :medium then "🟨 medium"
          when :low    then "🟩 low"
          else "⬜ unknown"
          end
        end

        def log_skipped_tasks
          skipped = TrainingSystem::Controller.skipped_task_titles_today
          return if skipped.empty?

          MemoryLogger.append(:skipped_tasks, skipped)
        end

        def log_swap_patterns(task_list)
          swaps = task_list.select { |t| t[:title].start_with?("[SWAP]") }
          return if swaps.empty?

          MemoryLogger.append(:swap_patterns, {
            date: Date.today.to_s,
            swaps: swaps.map { |t| t[:title] }
          })
        end

        def memory_tagging(task_list)
          tags = task_list.map do |task|
            {
              title: task[:title],
              role: task[:role_tag],
              emotion: ContextStack[:emotion],
              priority: task[:priority]
            }
          end

          MemoryLogger.append(:task_identity_tags, tags)
        end

        def default_self_care
          ["15m walk", "Shower", "Reflective journaling"]
        end

        def detect_focus(tasks)
          return :recovery if tasks.any? { |t| t[:title].match?(/recover|reset|pause/i) }
          ContextStack[:identity_mode] || :general
        end
      end
    end
  end
end
