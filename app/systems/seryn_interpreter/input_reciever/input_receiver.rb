# input_receiver.rb
# 🧠 Front interface of InterpreterSystem input — delegates to the full input_receiver/ subsystem

require_relative 'input_receiver/input_normalizer'
require_relative 'input_receiver/input_classifier'
require_relative 'input_receiver/source_auditor'

module InterpreterSystem
  class InputReceiver
    def self.capture(source = :user_prompt)
      raw_input = fetch_raw(source)

      normalized = InputNormalizer.clean(raw_input, source)
      input_type = InputClassifier.classify(normalized[:normalized])
      audited_source = SourceAuditor.audit(source)

      {
        cleaned_input: normalized[:normalized],
        input_type: input_type,
        source: audited_source,
        route_tag: route_tag_from(input_type),
        timestamp: normalized[:timestamp]
      }
    end

    private

    def self.fetch_raw(source)
      case source
      when :user_prompt
        puts "[InputReceiver] Awaiting user input:"
        gets.strip
      when :internal
        "[INTERNAL] reflection protocol requested"
      when :system
        "{trigger: 'task_blocked', source: 'ledger_core'}"
      else
        "Unrecognized input source"
      end
    end

    def self.route_tag_from(type)
      case type
      when :goal_statement then :strategy_request
      when :instruction    then :command_request
      when :journal_entry  then :emotional_log
      when :feedback       then :training_feedback
      else :undefined_route
      end
    end
  end
end
