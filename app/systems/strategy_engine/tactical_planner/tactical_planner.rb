# 📁 core/strategy/tactical_planner.rb

require_relative 'tactical_planner/objective_parser'
require_relative 'tactical_planner/constraint_extractor'
require_relative 'tactical_planner/phase_generator'
require_relative 'tactical_planner/fallback_strategy_suggestor'
require_relative 'tactical_planner/dependency_mapper'

module TacticalPlanner
  class << self

    def build_plan(raw_prompt)
      goal = ObjectiveParser.parse(raw_prompt)
      context = ConstraintExtractor.extract(goal)
      intel_summary = IntelGatherer.fetch(query: goal[:description], constraints: context)
      feasibility = ConstraintAnalyzer.evaluate(goal, context)
      tasks = PhaseGenerator.generate(goal, intel_summary[:options])
      fallback = FallbackStrategySuggestor.build(goal, context)
      dependencies = DependencyMapper.map(goal)

      assemble_strategy(goal, feasibility, tasks, fallback, intel_summary, dependencies)
    end

    def assemble_strategy(goal, feasibility, tasks, fallback, intel, dependencies)
      {
        strategy_id: goal[:id],
        goal: goal[:description],
        timeline: "#{Date.today} → #{goal[:deadline]}",
        milestone: goal[:milestone],
        tasks: tasks,
        fallback_ready: true,
        feasibility: feasibility,
        intel_summary: intel[:summary],
        mission_alignment: MissionCore.check_alignment(goal[:description]),
        dependencies: dependencies,
        status: :active,
        created_at: Time.now
      }
    end
  end
end
