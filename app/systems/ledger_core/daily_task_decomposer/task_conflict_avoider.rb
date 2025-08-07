# 📘 TaskConflictAvoider — Filters Tasks That Conflict with Identity, Mission, or Time Constraints
# Subcomponent of LedgerCore::DailyTaskDecomposer

require_relative '../../../mission_core/mission_core'
require_relative '../../../guardian_protocol/guardian_protocol'
require_relative '../../../interpreter_system/context_stack'

module LedgerCore
  module DailyTaskDecomposer
    module TaskConflictAvoider
      class << self
        def clean(task_list)
          identity    = ContextStack[:identity_mode] || MissionCore::Controller.current_role
          time_blocks = ContextStack[:available_blocks] || [:morning, :midday, :night]
          bandwidth   = ContextStack[:bandwidth] || :medium

          task_list.reject do |task|
            violates_identity?(task, identity) ||
            GuardianProtocol::Controller.blocked_task?(task[:title]) ||
            exceeds_bandwidth?(task, bandwidth) ||
            exceeds_time_block?(task, time_blocks)
          end
        end

        private

        def violates_identity?(task, role)
          return false unless role

          case role
          when :father
            task[:title].match?(/launch|project|client|meeting|pitch/i)
          when :builder
            task[:title].match?(/rest|pause|recover|reset/i)
          when :provider
            task[:title].match?(/art|creative|light/i)
          else
            false
          end
        end

        def exceeds_time_block?(task, available_blocks)
          return false if available_blocks.include?(:midday)
          task[:block_estimate] == :long && !available_blocks.include?(:long_block)
        end

        def exceeds_bandwidth?(task, bandwidth)
          case bandwidth
          when :low
            task[:priority] == :high
          when :medium
            false
          when :high
            false
          end
        end
      end
    end
  end
end
