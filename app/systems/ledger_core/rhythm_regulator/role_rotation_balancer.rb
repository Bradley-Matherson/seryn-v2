# 📘 RoleRotationBalancer — Ensures Healthy Rotation of Identity Roles
# Subcomponent of LedgerCore::RhythmRegulator

require_relative '../../../mission_core/mission_core'
require_relative '../../../memory/memory_logger'
require_relative '../../../response_engine/response_engine'
require_relative '../../task_memory_bank/controller'

module LedgerCore
  module RhythmRegulator
    module RoleRotationBalancer
      class << self
        def detect_neglect
          log = role_log
          neglected = log.find { |_, v| v[:days_since] >= neglect_threshold }

          if neglected
            role = neglected[0]
            days = neglected[1][:days_since]
            prompt = "You haven’t stepped into your #{role.to_s.capitalize} role for #{days} days. Want to schedule something in alignment?"

            ResponseEngine::Controller.inject_prompt(prompt)
            log_neglect(role, days)
            role
          else
            nil
          end
        end

        private

        def role_log
          roles = MissionCore::Controller.identity_roles
          roles.to_h do |role|
            last_active = MemoryLogger.get(:role_activity)&.dig(role) || Date.today - 99
            {
              days_since: (Date.today - last_active).to_i
            }
          end
        end

        def neglect_threshold
          4 # days of inactivity per role
        end

        def log_neglect(role, days)
          LedgerCore::TaskMemoryBank::Controller.log_role_neglect(
            role: role,
            days_inactive: days,
            timestamp: Time.now.utc.iso8601
          )
        end
      end
    end
  end
end
