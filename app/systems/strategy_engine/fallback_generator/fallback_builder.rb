# 📁 core/strategy/fallback_generator/fallback_builder.rb

module FallbackBuilder
  class << self
    def build(template)
      {
        name: template[:name],
        milestone: template[:milestone],
        tasks: structure_tasks(template[:phase_1]),
        resume_condition: set_resume_condition(template[:name])
      }
    end

    def structure_tasks(task_list)
      task_list.map.with_index do |task, i|
        {
          name: task,
          status: :pending,
          urgency: i.zero? ? :high : :medium,
          est_difficulty: :light
        }
      end
    end

    def set_resume_condition(template_name)
      case template_name
      when "Financial Reset Routine"
        "Available savings ≥ $100"
      when "Burnout Recovery Scaffold"
        "7 days of stable sleep and mood"
      when "Capacity Expansion Primer"
        "3+ hrs/day free for strategy execution"
      when "Mission Reflection Reset"
        "Guardian greenlight + personal alignment note"
      else
        "Daily task completion rate ≥ 60% for 5 days"
      end
    end
  end
end
