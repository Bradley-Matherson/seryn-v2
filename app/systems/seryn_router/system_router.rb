# core/system_router/system_router.rb

require_relative 'route_dispatcher'
require_relative 'system_registry'
require_relative 'route_confidence_evaluator'
require_relative 'fallback_manager'
require_relative 'guardian_hookpoint'
require_relative 'execution_trigger'
require_relative 'routing_log_emitter'
require_relative 'self_audit_trigger'

module SystemRouter
  class << self
    def route(interpreted_input)
      log_id = generate_log_id
      log_bundle = {
        log_id: log_id,
        original_input: interpreted_input[:original_input],
        interpreted_category: interpreted_input[:interpreted_category],
        confidence_from_interpreter: interpreted_input[:confidence]
      }

      target_system = interpreted_input[:system_target]
      system_info = SystemRegistry.lookup(target_system)

      log_bundle.merge!(
        target_system: target_system,
        system_available: system_info[:available],
        system_trust: system_info[:trust_level],
        system_health: system_info[:health]
      )

      routing_confidence = RouteConfidenceEvaluator.score(
        interpreted_input[:confidence],
        system_info[:trust_level],
        interpreted_input[:interpreted_category]
      )

      log_bundle[:routing_confidence] = routing_confidence

      if GuardianHookpoint.trigger?(interpreted_input, system_info)
        GuardianHookpoint.run(interpreted_input, log_id)
        log_bundle[:guardian_approval] = true
      else
        log_bundle[:guardian_approval] = false
      end

      route_result = RouteDispatcher.dispatch(interpreted_input, system_info)
      log_bundle[:fallback_used] = route_result[:fallback_used]
      log_bundle[:execution_success] = route_result[:execution_success]
      log_bundle[:final_target] = route_result[:final_target]

      RoutingLogEmitter.emit(log_bundle)
      SelfAuditTrigger.check

      {
        status: :routed,
        target_system: route_result[:final_target],
        fallback_used: route_result[:fallback_used],
        execution_success: route_result[:execution_success],
        routing_confidence: routing_confidence,
        guardian_approval: log_bundle[:guardian_approval],
        log_id: log_id
      }
    end

    private

    def generate_log_id
      "route_#{Time.now.strftime("%Y%m%dT%H%M%S")}"
    end
  end
end
