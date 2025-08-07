# interpretation_recorder.rb
# 🧾 Logs all interpretations to disk for historical analysis and training

require 'fileutils'

module InterpreterSystem
  class InterpretationRecorder
    LOG_PATH = "logs/interpreter"
    LOG_FILE = "#{LOG_PATH}/interpretation_history.log"

    def self.record(result, timestamp)
      FileUtils.mkdir_p(LOG_PATH)

      summary = "[#{timestamp.strftime('%Y-%m-%d %H:%M')}] " \
                "\"#{result[:input]}\" → #{result[:routed_to].to_s.capitalize} " \
                "(#{format('%.2f', result[:confidence_score])} confidence" \
                "#{result[:used_llm] ? ', LLM assisted' : ''}" \
                "#{result[:flagged] ? ', ⚠️ flagged' : ''})"

      File.open(LOG_FILE, 'a') { |f| f.puts summary }
    rescue => e
      puts "[InterpretationRecorder::ERROR] #{e.message}"
    end
  end
end
