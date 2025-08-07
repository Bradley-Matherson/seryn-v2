# input_normalizer.rb
# 🧽 Cleans and normalizes raw input for interpreter processing

module InterpreterSystem
  class InputNormalizer
    def self.clean(raw_input, source)
      cleaned = raw_input.strip.gsub(/[^a-zA-Z0-9\s,'".?!-]/, '').downcase

      {
        raw: raw_input,
        normalized: cleaned,
        source: source,
        timestamp: Time.now
      }
    end
  end
end
