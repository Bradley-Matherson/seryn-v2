# core/system_router/guardian_hookpoint.rb

require_relative '../guardian_protocol'

module GuardianHookpoint
  class << self
    def trigger?(interpreted_input, system_info)
      interpreted_input[:requires_guardian] ||
        system_info[:trust_level] < 0.4 ||
        risky_category?(interpreted_input[:interpreted_category])
    end

    def run(interpreted_input, log_id)
      GuardianProtocol.check_permission(interpreted_input)
      GuardianProtocol.record_routing({
        log_id: log_id,
        input: interpreted_input,
        triggered_by: :system_router
      })
    end

    private

    def risky_category?(category)
      category.include?("crisis") || category.include?("security") || category.include?("override")
    end
  end
end
