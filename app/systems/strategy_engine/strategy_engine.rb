# 📁 /seryn/strategy_engine/strategy_engine.rb

require_relative 'strategy_tracker/strategy_tracker'
require_relative 'strategy_registry/strategy_registry'
require_relative 'phase_progress_monitor/phase_progress_monitor'
require_relative 'resumption_trigger_watcher/resumption_trigger_watcher'
require_relative 'duplicate_prevention_filter/duplicate_prevention_filter'
require_relative 'realignment_prompt_dispatcher/realignment_prompt_dispatcher'
require_relative 'web_search_augmentor/web_search_augmentor'
require_relative 'constraint_analyzer/constraint_analyzer'
require_relative 'fallback_generator/fallback_generator'
require_relative 'tactical_planner/tactical_planner'

module StrategyEngine
  class << self

    def receive_prompt(prompt)
      return { error: "Empty prompt" } if prompt.strip.empty?

      parsed_goal = TacticalPlanner::ObjectiveParser.parse(prompt)
      return { error: "Unclear objective" } unless parsed_goal[:objective]

      return { duplicate: true, existing: true } if DuplicatePreventionFilter.duplicate?(parsed_goal)

      constraints = ConstraintAnalyzer.analyze(parsed_goal)
      return inject_fallback_if_blocked(parsed_goal, constraints) unless constraints[:strategy_feasible]

      enriched = WebSearchAugmentor.enrich_strategy(
        topic: parsed_goal[:objective],
        goal: parsed_goal[:goal_category],
        tags: parsed_goal[:tags],
        emotional_flags: parsed_goal[:emotional_context],
        constraints: constraints
      )

      full_plan = TacticalPlanner.generate(parsed_goal, constraints, enriched)

      StrategyRegistry.store(full_plan)
      StrategyTracker.track(full_plan)
      PhaseProgressMonitor.initialize_phases(full_plan)

      { strategy_id: full_plan[:id], status: :created, injected_to_ledger: true }
    end

    def inject_fallback_if_blocked(goal, constraints)
      fallback = FallbackGenerator.build(goal, constraints)
      StrategyRegistry.store_fallback(goal, fallback)
      StrategyTracker.flag_as_blocked(goal[:title])
      { fallback_injected: true, reason: constraints[:blocking_reason], fallback: fallback }
    end

    def auto_resume
      ResumptionTriggerWatcher.scan.each do |resumable|
        StrategyTracker.resume(resumable[:id])
        PhaseProgressMonitor.sync(resumable[:id])
      end
    end

    def current_state_report
      StrategyTracker.all.map do |s|
        {
          id: s[:id],
          title: s[:title],
          status: s[:status],
          progress: s[:progress],
          current_phase: s[:current_phase],
          drift: s[:drift_detected],
          resume_conditions: s[:resume_conditions]
        }
      end
    end
  end
end
