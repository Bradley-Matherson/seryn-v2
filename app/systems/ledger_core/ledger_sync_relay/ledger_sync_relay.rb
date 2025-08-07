# 📘 LedgerSyncRelay — Subsystem of LedgerCore
# Purpose: Route, render, and archive LedgerCore data to all relevant systems and outputs

require_relative 'data_broadcaster'
require_relative 'pdf_output_formatter'
require_relative 'ui_update_broadcaster'
require_relative 'archiver_and_purger'
require_relative 'sync_failure_handler'

module LedgerCore
  module LedgerSyncRelay
    class Controller
      class << self
        def sync_all(daily_state)
          snapshot = daily_state[:snapshot] || generate_snapshot(daily_state)
          pdf_path = PDFOutputFormatter.render_pdf(snapshot)
          DataBroadcaster.broadcast(snapshot)
          UIUpdateBroadcaster.send_update(snapshot)
          ArchiverAndPurger.run(snapshot)

          {
            synced: true,
            pdf_output: pdf_path,
            dashboard_output: "/dashboard/seryn/ledger.json",
            archived_to: ArchiverAndPurger.last_archive_path
          }
        rescue => e
          SyncFailureHandler.handle_error(e, context: "ledger_sync")
          { synced: false, error: e.message }
        end

        private

        def generate_snapshot(state)
          {
            date: Date.today.to_s,
            focus: state[:focus],
            energy: state[:energy_level],
            momentum: state[:momentum_level],
            streak: state.dig(:streaks, :journal_streak) || "untracked",
            identity_mode: state[:identity_mode],
            task_count: state[:tasks]&.size || 0,
            self_care: state[:self_care],
            reflections_due: state[:reflections_due]
          }
        end
      end
    end
  end
end
