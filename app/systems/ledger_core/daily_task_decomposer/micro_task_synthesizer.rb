# 📘 MicroTaskSynthesizer — Breaks Down Large Tasks into Simple Micro-Tasks
# Subcomponent of LedgerCore::DailyTaskDecomposer

require_relative '../../../interpreter_system/context_stack'

module LedgerCore
  module DailyTaskDecomposer
    module MicroTaskSynthesizer
      class << self
        def expand(task_list)
          emotion = ContextStack[:emotion] || :neutral
          role = ContextStack[:identity_mode] || :default

          task_list.flat_map do |task|
            expanded = expand_task(task, role, emotion)
            expanded.map { |t| tag_identity(t, role) }
          end
        end

        private

        def expand_task(task, role, emotion)
          case task[:title].downcase
          when /build credit plan/
            [
              format_micro("Review secured card options", :medium),
              format_micro("Write card application reminder", :low),
              format_micro("Add due date to calendar", :low)
            ]
          when /organize|review|setup/
            [
              format_micro("Open workspace or notes", :low),
              format_micro("Skim through related files", :low),
              format_micro("Outline next 2 steps", :medium)
            ]
          when /rest|recover/
            return [format_micro("Set 15-minute wind-down timer", :low)] if emotion == :overwhelmed
            return [format_micro("Quick check-in walk", :low)]
          else
            [task]
          end
        end

        def format_micro(title, priority)
          {
            title: title,
            priority: priority,
            block_estimate: estimate_time(priority),
            resources: []
          }
        end

        def estimate_time(priority)
          case priority
          when :low    then :short
          when :medium then :medium
          when :high   then :long
          else :medium
          end
        end

        def tag_identity(task, role)
          task.merge({ role_tag: role })
        end
      end
    end
  end
end
