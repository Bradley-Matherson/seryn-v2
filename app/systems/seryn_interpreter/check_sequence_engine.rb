# check_sequence_engine.rb
# 🧠 Executes the full interpretation pipeline and returns all results needed by RoutingOutput

require_relative 'auto_inference_classifier'
require_relative 'category_classifier'
require_relative 'intent_confidence_scorer'
require_relative 'context_integrator'
require_relative 'llm_assistance_trigger'
require_relative 'guardian_flagger'

module InterpreterSystem
  class CheckSequenceEngine
    def self.run(raw_input)
      puts "[CheckSequenceEngine] Running interpretation sequence..."

      # 1. Context Awareness
      context = ContextIntegrator.current_snapshot

      # 2. Inference Guess
      inference = AutoInferenceClassifier.guess(raw_input)

      # 3. Category Tagging
      category = CategoryClassifier.classify(raw_input, inference)

      # 4. Confidence Scoring
      confidence = IntentConfidenceScorer.score(raw_input, category, context)

      # 5. Guardian Safety Check
      guardian_flagged = GuardianFlagger.flag?(raw_input, category)

      # 6. Optional LLM Fallback
      requires_llm = confidence < 0.75
      llm_suggestion = requires_llm ? LLMAssistanceTrigger.call(raw_input, context) : nil
      target_system = llm_suggestion ? llm_suggestion[:suggested_target] : route_from_category(category)

      {
        category: category,
        confidence: confidence.round(2),
        guardian: guardian_flagged,
        llm: requires_llm,
        context: context,
        target: target_system
      }
    end

    def self.route_from_category(category)
      case category
      when /emotional/
        :alignment_memory
      when /financial/
        :strategy_engine
      when /task/
        :ledger_core
      when /identity/
        :mission_core
      when /crisis/
        :guardian_protocol
      else
        :interface_core
      end
    end
  end
end
