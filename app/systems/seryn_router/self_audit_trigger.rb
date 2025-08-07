# core/system_router/self_audit_trigger.rb

require_relative '../training_system'

module SelfAuditTrigger
  @audit_counter = 0
  @audit_interval = 10

  class << self
    def check
      @audit_counter += 1
      return unless @audit_counter >= @audit_interval

      begin
        TrainingSystem.review_recent_routes
        @audit_counter = 0
      rescue => e
        puts "[SelfAuditTrigger] Audit failed: #{e.message}"
      end
    end
  end
end
