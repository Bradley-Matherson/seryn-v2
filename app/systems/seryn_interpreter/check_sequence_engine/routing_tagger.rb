# routing_tagger.rb
# 🚦 Assigns the final route tag and Guardian status

module InterpreterSystem
  class RoutingTagger
    ROUTE_MAP = {
      strategy_request:      :strategy_engine,
      emotional_reflection:  :alignment_memory,
      task_edit:             :ledger_core,
      new_goal:              :mission_core,
      system_command:        :interface_core,
      ambiguous:             :interface_core
    }

    def self.resolve(intent:, confidence:, flagged:, origin:)
      route_tag = ROUTE_MAP[intent] || :interface_core

      guardian_check = if flagged
                         :flagged_for_review
                       elsif confidence < 0.5
                         :warning_low_confidence
                       else
                         :bypassed
                       end

      {
        route_tag: route_tag,
        guardian_check: guardian_check,
        origin: origin
      }
    end
  end
end
