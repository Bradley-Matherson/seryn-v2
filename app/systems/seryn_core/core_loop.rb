# 📁 core/core_loop.rb

require_relative "interpreter_system"
require_relative "system_router"
require_relative "response_engine"
require_relative "seryn_context_stack"
require_relative "system_matrix"
require_relative "guardian_protocol"

module CoreLoop
  class << self
    def process(input)
      log_input(input)

      interpretation = InterpreterSystem.parse(input)
      route_info = SystemRouter.route(interpretation)

      if route_info[:system].nil?
        fallback_response("I wasn't sure how to handle that. Let’s try a different way.")
        return
      end

      begin
        result = route_info[:system].call(route_info[:action], route_info[:params])
        deliver_output(result)
      rescue => e
        handle_failure(route_info[:system], e)
      end
    end

    private

    def log_input(input)
      puts "[CoreLoop] Received input: #{input}"
      SerynContextStack.update(:last_input, input)
    end

    def fallback_response(message)
      puts "[CoreLoop] Triggering fallback response."
      ResponseEngine.deliver(message: message, mode: :calm)
    end

    def handle_failure(system, error)
      puts "[CoreLoop] ERROR in #{system}: #{error.message}"
      SystemMatrix.mark_error(system)
      GuardianProtocol.flag(system, :failure)
      fallback_response("Something went wrong. I’ve logged the issue and we’ll reroute this moment.")
    end

    def deliver_output(output)
      puts "[CoreLoop] Output ready. Sending to ResponseEngine."
      ResponseEngine.deliver(message: output[:message], mode: output[:mode] || :default)
      SerynContextStack.update(:last_response, output[:message])
    end
  end
end
