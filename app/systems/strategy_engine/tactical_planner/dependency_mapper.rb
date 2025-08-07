# 📁 core/strategy/tactical_planner/dependency_mapper.rb

module DependencyMapper
  class << self
    def map_dependencies(phases)
      phases.each do |phase|
        phase[:tasks] = phase[:tasks].map do |task|
          wait_condition = detect_known_dependencies(task)
          {
            name: task,
            status: :pending,
            wait_for: wait_condition,
            trigger_condition: nil
          }
        end
      end
      phases
    end

    def detect_known_dependencies(task)
      task = task.downcase
      return :budget_complete if task.include?("credit") && task.include?("apply")
      return :score_logged if task.include?("secured") || task.include?("compare cards")
      return :buffer_built if task.include?("purchase") || task.include?("prequalify")
      return :income_tracked if task.include?("save") || task.include?("build savings")
      nil
    end
  end
end
