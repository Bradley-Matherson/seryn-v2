# 📁 /seryn/strategy_engine/strategy_tracker/strategy_tracker.rb

require_relative 'strategy_registry'
require_relative 'phase_progress_monitor'
require_relative 'resumption_trigger_watcher'
require_relative 'duplicate_prevention_filter'
require_relative 'realignment_prompt_dispatcher'

module StrategyTracker
  class << self
    # Register a new strategy and assign UID, metadata, etc.
    def register(strategy_hash)
      strategy = strategy_hash.dup
      strategy[:strategy_id] ||= generate_uid
      strategy[:status] = :active
      strategy[:created] ||= Time.now.iso8601
      strategy[:current_phase] ||= 1
      strategy[:progress] ||= 0
      strategy[:drift_detected] = false
      strategy[:required_systems] ||= [:ledger_core]
      strategy[:source] ||= :user_prompt
      strategy[:goal] ||= :unspecified
      strategy[:resume_conditions] ||= []

      StrategyRegistry.log(strategy)
    end

    # Called by LedgerCore or ResponseEngine to update strategy task state
    def update_progress(strategy_id, task_snapshot)
      PhaseProgressMonitor.update(strategy_id, task_snapshot)
    end

    # Periodically invoked by system loop
    def monitor_all
      ResumptionTriggerWatcher.scan
      RealignmentPromptDispatcher.trigger_if_needed
    end

    def check_for_duplicates(new_strategy)
      DuplicatePreventionFilter.detect(new_strategy)
    end

    def mark_strategy_paused(strategy_id, reason = nil)
      StrategyRegistry.update(strategy_id, {
        status: :paused,
        paused_on: Time.now.iso8601,
        pause_reason: reason
      })
    end

    def flag_for_realignment(strategy_id)
      StrategyRegistry.update(strategy_id, {
        drift_detected: true,
        needs_review: true
      })
    end

    def resume_strategy(strategy_id)
      StrategyRegistry.update(strategy_id, {
        status: :active,
        resumed_on: Time.now.iso8601,
        drift_detected: false,
        needs_review: false
      })
    end

    def all(status_filter = nil)
      StrategyRegistry.all(status_filter)
    end

    private

    def generate_uid
      "STRAT-#{Time.now.to_i}-#{rand(1000..9999)}"
    end
  end
end
