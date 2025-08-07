# 📘 MomentumScaler — Adjusts Task Load Based on Energy, Momentum, Identity Role
# Subcomponent of LedgerCore::DailyTaskDecomposer

require_relative '../../../training_system/training_system'
require_relative '../../../interpreter_system/context_stack'

module LedgerCore
  module DailyTaskDecomposer
    module MomentumScaler
      class << self
        def scale(tasks, identity_mode = nil)
          energy    = current_energy
          streak    = TrainingSystem::Controller.momentum_streak
          burnout   = TrainingSystem::Controller.burnout_warning?
          emotion   = ContextStack[:emotion] || :neutral

          return assign_recovery_tasks(identity_mode) if burnout
          return assign_minimum_tasks(tasks, identity_mode) if energy == :low && streak < 2
          return assign_full_phase(tasks, identity_mode) if energy == :high && streak >= 3

          assign_scaled(tasks, identity_mode, emotion)
        end

        private

        def current_energy
          ContextStack[:energy] || TrainingSystem::Controller.current_energy || :medium
        end

        def assign_minimum_tasks(tasks, identity_mode)
          core = role_specific_filter(tasks, identity_mode)
          core.select { |t| t[:priority] == :high }.first(1)
        end

        def assign_full_phase(tasks, identity_mode)
          role_specific_filter(tasks, identity_mode)
        end

        def assign_scaled(tasks, identity_mode, emotion)
          filtered = role_specific_filter(tasks, identity_mode)

          core = filtered.select { |t| [:high, :medium].include?(t[:priority]) }
          light = filtered.select { |t| t[:priority] == :low }

          limit = emotion == :overwhelmed ? 2 : 3
          core.first(limit) + light.first(1)
        end

        def role_specific_filter(tasks, role)
          return tasks unless role

          tasks.reject do |t|
            # For example, avoid pushing heavy work tasks in Father mode
            role == :father && t[:title].match?(/build|launch|strategy|email/i)
          end
        end

        def assign_recovery_tasks(identity_mode)
          base = [
            { title: "Recovery journaling", priority: :low, block_estimate: :short, resources: [] },
            { title: "Gentle walk or rest", priority: :low, block_estimate: :short, resources: [] }
          ]

          base << { title: "Check in with #{identity_mode.to_s.capitalize} role", priority: :low, block_estimate: :short, resources: [] } if identity_mode
          base
        end
      end
    end
  end
end
