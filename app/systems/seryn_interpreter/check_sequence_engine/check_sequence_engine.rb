# check_sequence_engine.rb
# 🧠 Orchestrates Seryn’s input evaluation pipeline — decides intent, confidence, safety, and routing

require_relative 'intent_confidence_scorer'
require_relative 'auto_inference_classifier'
require_relative 'llm_assistance_trigger'
require_relative 'guardian_hookpoint'
require_relative 'routing_tagger'

module InterpreterSystem
  class CheckSequenceEngine
    LLM_THRESHOLD = 0.65

    def self.run(input_package)
      puts "[CheckSequenceEngine] 🧠 Evaluating input: #{input_package[:cleaned_input]}"

      context = build_context(input_package)

      # 1. Inference guess
      inferred_intent = AutoInferenceClassifier.guess(input_package[:cleaned_input], context)

      # 2. Confidence score
      confidence_score = IntentConfidenceScorer.score(input_package[:cleaned_input], inferred_intent, context)

      # 3. LLM fallback
      used_llm = false
      if confidence_score < LLM_THRESHOLD
        puts "[CheckSequenceEngine] 🔄 Confidence low (#{confidence_score}). Activating LLM fallback..."
        llm_result = LLMAssistanceTrigger.call(input_package[:cleaned_input], context)
        inferred_intent = llm_result[:suggested_target]
        used_llm = true
      end

      # 4. Guardian flag check
      flagged = GuardianHookpoint.flagged?(input_package[:cleaned_input], inferred_intent)

      # 5. Routing decision
      route_info = RoutingTagger.resolve(
        intent: inferred_intent,
        confidence: confidence_score,
        flagged: flagged,
        origin: input_package[:source]
      )

      {
        interpreted_intent: inferred_intent,
        confidence_score: confidence_score.round(2),
        route_tag: route_info[:route_tag],
        flagged: flagged,
        used_llm: used_llm,
        guardian_check: route_info[:guardian_check],
        origin: input_package[:source]
      }
    end

    def self.build_context(input)
      {
        current_emotional_state: "neutral", # Replace with live context pull
        active_goal: "build passive income",
        recent_inputs: ["need to fix finances", "i’m stressed about spending"],
        input_type: input[:input_type],
        origin: input[:source]
      }
    end
  end
end