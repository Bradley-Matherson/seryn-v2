# seryn/guardian_protocol/behavioral_trust_engine/decay_monitor.rb

require_relative 'trust_ledger'

module DecayMonitor
  def self.apply(system:, context:)
    decay = 0.0

    decay += 0.015 if context[:user_feedback] == :negative
    decay += 0.01 if context[:task_accuracy] && context[:task_accuracy] < 0.7
    decay += 0.02 if context[:spiral_mishandled] == true
    decay += 0.015 if context[:misalignment_count].to_i > 2

    if decay > 0
      TrustLedger.log_entry(system: system, delta: -decay, context: context.merge(decay_applied: true))
    end
  end
end
