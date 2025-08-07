# guardian_flagger.rb
# 🛡️ Detects risky, harmful, or security-compromising input and triggers Guardian protocols

module InterpreterSystem
  class GuardianFlagger
    RISK_PATTERNS = [
      /erase\s+memory/i,
      /delete\s+all/i,
      /shutdown/i,
      /kill\s+(self|seryn)/i,
      /i\s+give\s+up/i,
      /i\s+don['’]?t\s+want\s+to\s+go\s+on/i,
      /what's\s+the\s+point/i,
      /i\s+hate\s+everything/i,
      /nothing\s+matters/i,
      /i\s+wish\s+i\s+wasn['’]?t\s+here/i,
      /harm\s+(myself|others)/i
    ]

    def self.flag?(input, category)
      flagged = false

      # 1. Explicit risk patterns
      RISK_PATTERNS.each do |pattern|
        if input =~ pattern
          flagged = true
          puts "[GuardianFlagger] ⚠️ Risk pattern detected: #{pattern.source}"
          break
        end
      end

      # 2. Implicit escalation based on category
      if category == "crisis.intervention.possible"
        flagged = true
        puts "[GuardianFlagger] 🚨 Crisis-level input category"
      end

      flagged
    end
  end
end
