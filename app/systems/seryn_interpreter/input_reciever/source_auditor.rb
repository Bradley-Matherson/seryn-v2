# source_auditor.rb
# 🔍 Confirms and logs input origin — used for recursion protection and audit trust

module InterpreterSystem
  class SourceAuditor
    TRUSTED_SOURCES = [:user_prompt, :system, :internal]
    FLAGGED_PATTERNS = [
      /llm/i,
      /generated_by/i,
      /autonomous_reflection/i,
      /ai_response/i
    ]

    def self.audit(source)
      return :untrusted if !TRUSTED_SOURCES.include?(source)

      # In future: scan input metadata if needed (e.g., for hallucination recursion)
      # Here, we just return the source directly for now
      source
    end

    def self.untrustworthy?(input_string)
      FLAGGED_PATTERNS.any? { |pattern| input_string.match?(pattern) }
    end
  end
end
