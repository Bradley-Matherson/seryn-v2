# 📘 UIUpdateBroadcaster — Sends Structured Updates to Real-Time UI Clients
# Subcomponent of LedgerCore::LedgerSyncRelay

require 'json'
require 'fileutils'

module LedgerCore
  module LedgerSyncRelay
    module UIUpdateBroadcaster
      DASHBOARD_PATH = "./dashboard/seryn/ledger.json"

      class << self
        def send_update(snapshot)
          FileUtils.mkdir_p(File.dirname(DASHBOARD_PATH))

          payload = {
            updated_at: Time.now.utc.iso8601,
            type: "ledger_snapshot",
            focus: snapshot[:focus],
            energy: snapshot[:energy],
            momentum: snapshot[:momentum],
            streak: snapshot[:streak],
            identity_mode: snapshot[:identity_mode],
            task_count: snapshot[:task_count],
            self_care: snapshot[:self_care],
            reflections_due: snapshot[:reflections_due],
            milestones: format_milestones(snapshot[:milestones] || [])
          }

          File.write(DASHBOARD_PATH, JSON.pretty_generate(payload))
          DASHBOARD_PATH
        end

        private

        def format_milestones(milestones)
          milestones.map do |m|
            {
              id: m[:id],
              progress: m[:progress],
              status: m[:trajectory],
              color: determine_color(m)
            }
          end
        end

        def determine_color(milestone)
          return "gray" if milestone[:blocked]
          case milestone[:trajectory]
          when :on_track   then "green"
          when :improving  then "blue"
          when :stalled    then "orange"
          when :blocked    then "red"
          else "lightgray"
          end
        end
      end
    end
  end
end
