# core/system_router/execution_trigger.rb

module ExecutionTrigger
  class << self
    def run(target_system, input_bundle)
      begin
        klass = Object.const_get(camelize(target_system))
        result = klass.execute(input_bundle)

        {
          success: true,
          system: target_system,
          output: result
        }
      rescue => e
        puts "[ExecutionTrigger] Failed to execute #{target_system}: #{e.message}"
        {
          success: false,
          system: target_system,
          output: nil
        }
      end
    end

    private

    def camelize(symbol)
      symbol.to_s.split('_').map(&:capitalize).join
    end
  end
end
