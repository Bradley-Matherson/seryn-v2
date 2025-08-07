# interpreter.rb
# 🧠 Seryn InterpreterSystem Main File
# Responsible for orchestrating the full input interpretation and routing output.

require_relative 'input_receiver'
require_relative 'check_sequence_engine'
require_relative 'routing_output'

module InterpreterSystem
  class Interpreter
    def self.process(input_source: :user)
      # 1. Capture input from the appropriate origin
      raw_input = InputReceiver.capture(input_source)

      # 2. Run the full interpretation sequence
      interpreted_result = CheckSequenceEngine.run(raw_input)

      # 3. Package into a RoutingOutput
      routing_package = RoutingOutput.build(
        original_input: raw_input,
        interpreted_category: interpreted_result[:category],
        confidence: interpreted_result[:confidence],
        system_target: interpreted_result[:target],
        requires_guardian: interpreted_result[:guardian],
        requires_llm: interpreted_result[:llm],
        context_snapshot: interpreted_result[:context],
        timestamp: Time.now
      )

      # 4. Return for further use (SystemRouter or logging)
      routing_package
    end
  end
end
