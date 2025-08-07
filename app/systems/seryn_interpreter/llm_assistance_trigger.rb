# llm_assistance_trigger.rb
# 🧠 Fallback logic using open-source LLM (e.g., OpenChat, Mistral, Ollama, etc.)

require 'net/http'
require 'uri'
require 'json'

module InterpreterSystem
  class LLMAssistanceTrigger
    LLM_ENDPOINT = "http://localhost:11434/v1/chat/completions" # Modify as needed
    MODEL_NAME = "openchat" # or "mistral", "llama2", etc.

    def self.call(input, context)
      puts "[LLMAssistanceTrigger] Confidence too low — sending to open LLM..."

      prompt = build_prompt(input, context)
      response = query_llm(prompt)

      {
        prompt_used: prompt,
        suggested_target: extract_system_target(response),
        summary: extract_summary(response)
      }
    end

    def self.build_prompt(input, context)
      <<~PROMPT
        User input: "#{input}"

        Context:
        - Emotional state: #{context[:current_emotional_state]}
        - Active goal: #{context[:active_goal]}
        - Current focus: #{context[:ledger_task_focus]}
        - Energy level: #{context[:energy_level]}
        - Recent patterns: #{context[:recent_patterns].join(', ')}

        Based on this input and context, summarize the user’s intent and recommend which internal system (like alignment_memory, strategy_engine, ledger_core, etc.) should handle it.
        Respond in JSON format like:
        {
          "intent_summary": "...",
          "target_system": "..."
        }
      PROMPT
    end

    def self.query_llm(prompt)
      uri = URI.parse(LLM_ENDPOINT)
      http = Net::HTTP.new(uri.host, uri.port)
      headers = { 'Content-Type' => 'application/json' }

      request_body = {
        model: MODEL_NAME,
        messages: [
          { role: "system", content: "You are an intent classification assistant for a modular AI system." },
          { role: "user", content: prompt }
        ],
        temperature: 0.4
      }.to_json

      response = http.post(uri.path, request_body, headers)
      parsed = JSON.parse(response.body)
      parsed["choices"][0]["message"]["content"]
    rescue => e
      puts "[LLMAssistanceTrigger::ERROR] #{e.message}"
      fallback_json
    end

    def self.extract_summary(response_text)
      parsed = JSON.parse(response_text) rescue fallback_json
      parsed["intent_summary"]
    end

    def self.extract_system_target(response_text)
      parsed = JSON.parse(response_text) rescue fallback_json
      parsed["target_system"]&.to_sym || :interface_core
    end

    def self.fallback_json
      {
        "intent_summary" => "Unable to interpret. Route to interface for clarification.",
        "target_system" => "interface_core"
      }
    end
  end
end
