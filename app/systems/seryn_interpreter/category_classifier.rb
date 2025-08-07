# category_classifier.rb
# 🧠 Applies domain-specific tagging to input, based on raw content + inferred guess

module InterpreterSystem
  class CategoryClassifier
    def self.classify(input, inference)
      input_down = input.downcase

      case inference
      when 'journal'
        input_down.include?("stuck") || input_down.include?("confused") ? "emotional.journaling.stuck" : "emotional.journaling.open"
      when 'financial'
        input_down.include?("invest") ? "financial.investment.query" : "financial.strategy.request"
      when 'task'
        input_down.include?("checklist") ? "task.review" : "task.override"
      when 'identity'
        input_down.include?("purpose") ? "identity.purpose.confirmation" : "identity.confirmation"
      when 'spiral'
        "emotional.spiral.possible"
      when 'emotion'
        "emotional.status.report"
      when 'command'
        "system.command.request"
      when 'review'
        "task.review.request"
      when 'crisis'
        "crisis.intervention.possible"
      else
        "unclassified.input.general"
      end
    end
  end
end
