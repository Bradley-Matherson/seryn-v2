# seryn/guardian_protocol/violation_scanner/severity_assessor.rb

module SeverityAssessor
  def self.evaluate(context, signature)
    emotional_state = context[:user_state] || :stable
    repeat_pattern = context[:repeat_count].to_i > 2
    permission_ok = context[:permission] == :approved

    escalated_severity =
      if signature[:severity] == :high && emotional_state == :spiraling
        :critical
      elsif repeat_pattern
        :elevated
      else
        signature[:severity]
      end

    {
      flagged: true,
      id: signature[:id],
      severity: escalated_severity,
      reason: signature[:reason],
      trigger: context[:source],
      system_action: signature[:action],
      user_notified: true,
      override_allowed: (signature[:action] != :lockdown),
      trust_penalty: trust_penalty_from(severity: escalated_severity, repeat: repeat_pattern),
      timestamp: Time.now
    }
  end

  def self.trust_penalty_from(severity:, repeat:)
    base = case severity
           when :critical then 0.05
           when :high     then 0.03
           when :moderate then 0.015
           else 0.005
           end
    repeat ? base * 1.5 : base
  end
end
