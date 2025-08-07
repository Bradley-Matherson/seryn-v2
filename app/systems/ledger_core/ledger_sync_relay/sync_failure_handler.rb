# 📘 SyncFailureHandler — Handles Sync Errors and Escalates if Needed
# Subcomponent of LedgerCore::LedgerSyncRelay

require_relative '../../../guardian_protocol/guardian_protocol'
require 'fileutils'
require 'yaml'

module LedgerCore
  module LedgerSyncRelay
    module SyncFailureHandler
      LOG_PATH = "./logs/ledger/sync_failures.log"

      class << self
        def handle_error(error, context: "unknown")
          FileUtils.mkdir_p(File.dirname(LOG_PATH))

          log_entry = build_log(error, context)
          File.open(LOG_PATH, "a") { |f| f.puts(log_entry.to_yaml + "\n---") }

          escalate_if_critical(error, context)
        end

        private

        def build_log(error, context)
          {
            time: Time.now.utc.iso8601,
            context: context,
            error: error.message,
            class: error.class.to_s,
            backtrace: error.backtrace&.first(10)
          }
        end

        def escalate_if_critical(error, context)
          critical = error.message.match?(/corrupt|unreadable|nil|missing|fatal/i)

          if critical
            GuardianProtocol::Controller.flag(:critical_sync_failure, {
              source: :ledger_sync,
              context: context,
              message: error.message,
              class: error.class.to_s,
              time: Time.now.utc.iso8601
            })
          end
        end
      end
    end
  end
end
