# 📁 seryn/systems/output_control/output_archive/daily_output_logger.rb

require "fileutils"
require "time"

module DailyOutputLogger
  OUTPUT_DIR = "outputs/daily"
  @last_logged = nil

  class << self
    def log(output, options = {})
      date_str = Time.now.strftime("%Y-%m-%d")
      path = File.join(OUTPUT_DIR, "#{date_str}.log")
      FileUtils.mkdir_p(OUTPUT_DIR)

      log_entry = format_log(output, options)

      File.open(path, "a") do |file|
        file.puts("\n[#{Time.now.strftime('%H:%M:%S')}] #{output[:type].to_s.capitalize}")
        file.puts(log_entry)
        file.puts("-" * 40)
      end

      @last_logged = Time.now
    end

    def last_logged_at
      @last_logged
    end

    private

    def format_log(output, opts = {})
      data = output[:content].dup

      if opts[:include_emotion_trace]
        emotion = output[:mood] || "unknown"
        data += "\n[Emotion Trace] #{emotion}"
      end

      if opts[:include_response_phrasing]
        data += "\n[Phrasing Tag] #{output[:phrasing] || 'N/A'}"
      end

      if opts[:include_skipped_sections]
        data += "\n[Skipped] #{output[:skipped]&.join(', ') || 'none'}"
      end

      data
    end
  end
end
