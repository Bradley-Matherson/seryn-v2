# guardian_hookpoint.rb
# 🛡️ Flags dangerous or mission-violating input before routing

module InterpreterSystem
  class GuardianHookpoint
    RISK_PATTERNS = [
      /erase\s+(memory|everything)/i,
      /delete\s+(everything|yourself|logs)/i,
      /shutdown/i,
      /kill\s+(myself|seryn)/i,
      /i\s+give\s+up/i,
      /nothing\s+matters/i,
      /i\s+hate\s+(myself|you)/i,
      /i\s+wish\s+i\s+wasn['’]?t\s+here/i,
      /i\s+don['’]?t\s+care/i,
      /stop\s+caring/i
    ]

    ESCALATED_INTENTS = [:crisis_trigger, :destruction_command]

    def self.flagged?(text, inferred_intent)
      flagged_by_pattern?(text) || flagged_by_intent?(inferred_intent)
    end

    def self.flagged_by_pattern?(text)
      RISK_PATTERNS.any? { |pattern| text.match?(pattern) }
    end

    def self.flagged_by_intent?(intent)
      ESCALATED_INTENTS.include?(intent.to_sym)
    end
  end
end
