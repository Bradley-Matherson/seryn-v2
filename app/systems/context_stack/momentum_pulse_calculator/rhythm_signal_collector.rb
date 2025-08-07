# rhythm_signal_collector.rb
# 📡 RhythmSignalCollector — gathers momentum-related activity for current day

require_relative "../../ledger_core/ledger_core"
require_relative "../../training_system/journal_parser"
require_relative "../../seryn_core/system_registry"
require_relative "../../guardian_protocol/spiral_log"

module RhythmSignalCollector
  @snapshot = {}

  def self.collect
    @snapshot = {
      tasks_completed: LedgerCore.tasks_completed_today,
      reflections: JournalParser.entries_today.count,
      spiral: SpiralLog.spiral_today?,
      engagement_hours: SystemRegistry.hours_active_today,
      strategy_tasks_done: LedgerCore.strategy_task_count_today
    }
  end

  def self.snapshot
    @snapshot
  end
end
