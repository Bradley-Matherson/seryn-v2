# core/system_router/route_dispatcher.rb

require_relative 'fallback_manager'
require_relative 'execution_trigger'

module RouteDispatcher
  class << self
    def dispatch(interpreted_input, system_info)
      primary_target = interpreted_input[:system_target]

      if routeable?(system_info)
        result = ExecutionTrigger.run(primary_target, interpreted_input)
        return {
          fallback_used: false,
          execution_success: result[:success],
          final_target: primary_target
        }
      else
        fallback_target = FallbackManager.resolve(primary_target)
        result = ExecutionTrigger.run(fallback_target, interpreted_input)
        return {
          fallback_used: true,
          execution_success: result[:success],
          final_target: fallback_target
        }
      end
    end

    private

    def routeable?(system_info)
      system_info[:available] &&
        system_info[:trust_level] >= 0.5 &&
        system_info[:health] == :pass
    end
  end
end
