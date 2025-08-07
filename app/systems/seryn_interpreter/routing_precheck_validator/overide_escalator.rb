# override_escalator.rb
# 🛑 If a request violates integrity, but might be intentional, trigger Guardian override flow

module InterpreterSystem
  class OverrideEscalator
    ESCALATABLE_INTENTS = [
      :strategy_request,
      :goal_override,
      :task_replacement,
      :system_command,
      :alignment_reversal
    ]

    ESCALATION_TRIGGERS = [
      /force this/i,
      /i don.?t care/i,
      /just do it/i,
      /override/i,
      /i need it anyway/i,
      /i'm doing it regardless/i
    ]

    def self.trigger?(intent, context)
      return true if escalatable_intent?(intent)
      return true if escalation_language_detected?(context[:raw_input])
      false
    end

    def self.escalatable_intent?(intent)
      ESCALATABLE_INTENTS.include?(intent.to_sym)
    end

    def self.escalation_language_detected?(input)
      return false unless input
      ESCALATION_TRIGGERS.any? { |pattern| input.match?(pattern) }
    end
  end
end
