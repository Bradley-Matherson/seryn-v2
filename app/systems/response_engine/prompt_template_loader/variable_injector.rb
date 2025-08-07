# seryn/response_engine/prompt_template_loader/variable_injector.rb

require_relative '../../mission/mission_core'
require_relative '../../training/training_system'
require_relative '../../strategy/strategy_engine'

module ResponseEngine
  module PromptTemplateLoader
    module VariableInjector
      @last_used_values = {}

      class << self
        def fill(template:, context:)
          mission   = MissionCore.current_mission_snapshot
          training  = TrainingSystem.snapshot
          strategy  = StrategyEngine.current_status

          @last_used_values = {
            goal:           mission[:active_goal] || "your current goal",
            energy:         training[:energy] || "moderate",
            emotional_state: training[:emotional_state] || "neutral",
            milestone:      strategy[:active_milestone] || "your next step",
            pillar:         mission[:dominant_pillar] || "your why",
            role:           mission[:active_identity_mode] || "you",
            trust_score:    training[:trust_score] || "growing"
          }

          @last_used_values
        end

        def last_used_values
          @last_used_values
        end
      end
    end
  end
end
