# seryn/response_engine/llm_query_engine/response_bridge.rb

require 'fileutils'
require 'time'

module ResponseEngine
  module LLMQueryEngine
    module ResponseBridge
      LOG_DIR = 'logs/response/llm_generated'

      class << self
        def finalize(content:, model:, tone:, flags:, trigger:)
          log_response(content: content, model: model, tone: tone, flags: flags, trigger: trigger)

          {
            source: :llm,
            model: model,
            tone: tone,
            trigger: trigger,
            flags: flags,
            result: format(content, flags),
            output_type: :structured_response,
            yaml_ready: true
          }
        end

        private

        def format(text, flags)
          return add_audio_markup(text) if flags.include?(:audio_friendly)
          return format_markdown(text) if flags.include?(:markdown)

          text.strip
        end

        def add_audio_markup(text)
          text.gsub(/\n+/, " <pause> ").strip
        end

        def format_markdown(text)
          "**Reflection:**\n\n#{text.strip}"
        end

        def log_response(content:, model:, tone:, flags:, trigger:)
          FileUtils.mkdir_p(LOG_DIR)
          file = File.join(LOG_DIR, "#{Time.now.strftime('%Y-%m-%d')}.log")

          File.open(file, 'a') do |f|
            f.puts "---"
            f.puts "Time: #{Time.now.utc.iso8601}"
            f.puts "Model: #{model}"
            f.puts "Tone: #{tone}"
            f.puts "Trigger: #{trigger}"
            f.puts "Flags: #{flags.join(', ')}"
            f.puts "Content:"
            f.puts content.strip
            f.puts "---\n\n"
          end
        end
      end
    end
  end
end
