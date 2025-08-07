# 📁 seryn/systems/output_control/output_formatter/content_sanitizer.rb

module OutputFormatter
  module ContentSanitizer
    CODE_TRANSLATIONS = {
      streak_reinforced: "Streak Boost Active",
      drift_detected: "⚠️ Drift Detected",
      locked_in: "✅ Locked In",
      momentum_low: "⚠️ Low Momentum"
    }

    class << self
      def clean(raw_payload)
        cleaned = {}

        raw_payload.each do |key, value|
          cleaned[key] = sanitize_value(value)
        end

        cleaned
      end

      private

      def sanitize_value(value)
        case value
        when String
          escape_text(value)
        when Symbol
          translate_symbol(value)
        when Array
          value.map { |item| sanitize_value(item) }.compact
        when Hash
          value.transform_values { |v| sanitize_value(v) }
        else
          value
        end
      end

      def escape_text(text)
        text
          .gsub(/<script.*?>.*?<\/script>/, "")     # Strip any script tags
          .gsub(/[<>]/, "")                         # Remove angle brackets
          .strip
      end

      def translate_symbol(symbol)
        CODE_TRANSLATIONS[symbol] || symbol.to_s.gsub("_", " ").capitalize
      end
    end
  end
end
