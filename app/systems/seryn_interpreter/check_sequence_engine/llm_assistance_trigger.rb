# llm_assistance_trigger.rb
# 🤖 Uses fallback LLM to recover intent from vague or low-confidence input

require 'net/http'
require 'json'
require 'uri'

module InterpreterSystem
  class LLMAssistanceTrigger
    LLM_API_URL = "http://localhost:11434/v1/chat/completions" # Update to match your local LLM endpoint
    MODEL_NAME = "mistral" # Replace with your hosted model name

    def self.call(input, context)
      puts "[LLMAssistanceTrigger] 🤖 Invoking LLM for clarification..."

      prompt = build_prompt(input, context)
      response_json = send_request(prompt)

      {
        prompt_used: prompt,
        suggested_target: response_json["target_system"]&.to_sym || :interface_core,
        summary: response_json["intent_summary"] || "Unclear intent"
      }
    end

    def self.build_prompt(input, context)
      <<~PROMPT
        Interpret the following input and respond in JSON format:
        {
          "intent_summary": "...",
          "target_system": "..."
        }

        Input: "#{input}"

        Context:
        - Emotion: #{context[:current_emotional_state]}
        - Goal: #{context[:active_goal]}
        - Origin: #{context[:origin]}
        - Recent inputs: #{context[:recent_inputs].join(' | ')}
      PROMPT
    end

    def self.send_request(prompt)
      uri = URI.parse(LLM_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, { 'Content-Type': 'application/json' })

      request.body = {
        model: MODEL_NAME,
        messages: [
          { role: "system", content: "You are a classification assistant that summarizes user input and selects the correct internal system route." },
          { role: "user", content: prompt }
        ],
        temperature: 0.3
      }.to_json

      response = http.request(request)
      content = JSON.parse(response.body).dig("choices", 0, "message", "content")
      JSON.parse(content) rescue fallback_response
    rescue => e
      puts "[LLMAssistanceTrigger::ERROR] #{e.message}"
      fallback_response
    end

    def self.fallback_response
      {
        "intent_summary" => "Could not interpret clearly.",
        "target_system" => "interface_core"
      }
    end
  end
end
