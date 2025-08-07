# 📁 /seryn/strategy_engine/strategy_tracker/resumption_trigger_watcher.rb

require_relative 'strategy_registry'
require_relative '../../../context_stack'
require_relative '../../../ledger_core'
require_relative '../../../guardian_protocol'
require_relative '../../../training_system'
require_relative '../../../strategy_engine/strategy_tracker/strategy_tracker'

module ResumptionTriggerWatcher
  CONFIDENCE_THRESHOLD = 0.80
  ARCHIVE_AFTER_DAYS = 30

  class << self
    def scan
      strategies = StrategyRegistry.all
      targets = strategies.select { |s| [:paused, :blocked, :delayed].include?(s[:status]&.to_sym) }

      targets.each do |strategy|
        if stale?(strategy)
          archive(strategy)
        else
          score = calculate_resume_score(strategy)
          if score >= CONFIDENCE_THRESHOLD && permitted_to_resume?(strategy)
            notify_or_resume(strategy, score)
          end
        end
      end
    end

    def stale?(strategy)
      last = Time.parse(strategy[:last_used_at] || strategy[:created_at]) rescue return false
      (Time.now - last) / 86_400.0 > ARCHIVE_AFTER_DAYS
    end

    def archive(strategy)
      StrategyRegistry.update(strategy[:id], { status: :archived, archived_on: Time.now.iso8601 })
      TrainingSystem.log_pattern(:strategy_dropped, strategy[:id])
    end

    def calculate_resume_score(strategy)
      score = 1.0
      score -= 0.25 if ContextStack[:energy] == :low
      score -= 0.2 if ContextStack[:mood] == :foggy
      score -= 0.15 if LedgerCore.task_backlog > 2
      score -= 0.15 if strategy[:status].to_sym == :blocked
      score -= 0.1 if strategy[:resume_conditions]&.any? { |c| unmet?(c) }

      score = [score, 0.0].max
      score.round(2)
    end

    def unmet?(condition)
      case condition.to_s
      when /momentum_restored/
        (ContextStack[:momentum_score] || 0.0) < 0.5
      when /backlog_cleared/
        LedgerCore.task_backlog > 1
      when /identity_role=(.+)/
        ContextStack[:identity_role]&.to_s != $1
      else
        false
      end
    end

    def permitted_to_resume?(strategy)
      GuardianProtocol.permits?(:strategy_resume)
    end

    def notify_or_resume(strategy, score)
      msg = "You're ready to resume the momentum on **#{strategy[:title]}** (score: #{score}). Want me to activate it?"

      StrategyTracker.resume_strategy(strategy[:id])
      LedgerCore.inject_tasks_for(strategy[:id]) if LedgerCore.respond_to?(:inject_tasks_for)
      ResponseEngine.deliver_soft_prompt(msg)
      TrainingSystem.log_pattern(:strategy_resumed, strategy[:id])
    end
  end
end
