# 📁 /seryn/strategy_engine/web_search_augmentor/web_adapter_router.rb

require 'net/http'
require 'uri'
require 'json'

module WebAdapterRouter
  OPENAI_ENDPOINT = "https://api.openai.com/v1/chat/completions"

  class << self
    def search(query:)
      api_key = ENV['OPENAI_API_KEY']
      raise "Missing OPENAI_API_KEY" unless api_key

      payload = {
        model: "gpt-4o", # or gpt-4-1106-preview
        messages: [
          { role: "system", content: "You are Seryn’s real-world researcher. Search the internet and return accurate, up-to-date, expert-backed information relevant to the following question." },
          { role: "user", content: query }
        ],
        tools: [
          { type: "browser" }
        ],
        tool_choice: "auto"
      }

      response = http_post(OPENAI_ENDPOINT, payload, api_key)
      parsed = JSON.parse(response)

      content = parsed.dig("choices", 0, "message", "content") || "No results"
      extract_results_from(content, query)
    end

    def extract_results_from(text, query)
      [{
        title: "Search Results for: #{query}",
        url: "https://www.google.com/search?q=#{URI.encode(query)}",
        summary: text.strip,
        source: "openai.com",
        confidence_score: 0.92,
        recency: "live"
      }]
    end

    def http_post(uri, body, api_key)
      url = URI(uri)
      req = Net::HTTP::Post.new(url)
      req["Authorization"] = "Bearer #{api_key}"
      req["Content-Type"] = "application/json"
      req.body = body.to_json

      res = Net::HTTP.start(url.hostname, url.port, use_ssl: true) do |http|
        http.request(req)
      end

      raise "API Error: #{res.code}" unless res.code.to_i == 200
      res.body
    end
  end
end
