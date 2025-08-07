# 📘 DataBroadcaster — Sends Tagged Ledger Data to All Core Systems
# Subcomponent of LedgerCore::LedgerSyncRelay

require_relative '../../../seryn_core/seryn_core'
require_relative '../../../response_engine/response_engine'
require_relative '../../../training_system/training_system'
require_relative '../../../strategy_engine/strategy_engine'
require_relative '../../../guardian_protocol/guardian_protocol'

module LedgerCore
  module LedgerSyncRelay
    module DataBroadcaster
      class << self
        def broadcast(snapshot)
          tagged = tag(snapshot)

          SerynCore::Controller.update_dashboard(tagged)
          ResponseEngine::Controller.inject_summary(tagged)
          TrainingSystem::Controller.log_consistency(tagged)
          StrategyEngine::Controller.receive_task_update(tagged)
          GuardianProtocol::Controller.sync_check(tagged)
        end

        private

        def tag(data)
          {
            type: :ledger_daily_snapshot,
            timestamp: Time.now.utc.iso8601,
            source: :LedgerCore,
            payload: data
          }
        end
      end
    end
  end
end
