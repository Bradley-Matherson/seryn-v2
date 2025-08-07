# 📁 /seryn/strategy_engine/phase_progress_monitor/phase_progress_monitor.rb

require_relative '../strategy_tracker/strategy_registry'
require_relative '../../context_stack'
require_relative '../../guardian_protocol'
require_relative '../../mission_core'
require_relative '../../training_system'

module PhaseProgressMonitor
  class << self
    def update_progress(strategy_id, task_snapshot)
      strategy = StrategyRegistry.find(strategy_id)
      return unless strategy && strategy[:phases]

      current_index = strategy[:current_phase] || 0
      phase = strategy[:phases][current_index]
      return unless phase

      completed = task_snapshot.count { |t| t[:status] == :complete }
      total     = task_snapshot.size
      percent   = total > 0 ? (completed.to_f / total * 100).round : 0

      StrategyRegistry.update(strategy_id, {
        progress: percent,
        last_phase_update: Time.now.iso8601
      })

      evaluate_phase_transition(strategy, phase, strategy_id, percent)
    end

    def evaluate_phase_transition(strategy, phase, strategy_id, percent)
      unlock_met = unlock_condition_met?(strategy, phase, percent)
      blocked_reason = check_blockers(strategy, phase)

      if unlock_met && !blocked_reason
        advance_phase(strategy_id)
      elsif blocked_reason
        StrategyRegistry.update(strategy_id, {
          phase_blocked: true,
          block_reason: blocked_reason
        })
        notify_block(strategy, blocked_reason)
      end
    end

    def unlock_condition_met?(strategy, phase, percent)
      cond = phase[:unlock_condition]
      return true unless cond

      case cond
      when /ledger_streak\s*>=\s*(\d+)/i
        LedgerCore.streak_count >= $1.to_i
      when /strategy_progress\s*>=\s*(\d+)%/
        percent >= $1.to_i
      else
        true
      end
    end

    def check_blockers(strategy, phase)
      next_phase_index = (strategy[:current_phase] || 0) + 1
      next_phase = strategy[:phases][next_phase_index]
      return nil unless next_phase

      return "energy_level too low" if [:low, :very_low].include?(ContextStack[:energy])
      return "guardian block" if GuardianProtocol.execution_block_active?
      return "identity_role misaligned" if MissionCore.misaligned?(next_phase)

      nil
    end

    def advance_phase(strategy_id)
      strategy = StrategyRegistry.find(strategy_id)
      return unless strategy

      new_index = (strategy[:current_phase] || 0) + 1
      return if new_index >= strategy[:phases].length

      StrategyRegistry.update(strategy_id, {
        current_phase: new_index,
        phase_blocked: false,
        block_reason: nil
      })

      TrainingSystem.log_pattern(:phase_advanced, strategy_id)
    end

    def notify_block(strategy, reason)
      OutputEngine.show_warning("🚧 Strategy '#{strategy[:title]}' is blocked from advancing: #{reason}")
    end
  end
end
