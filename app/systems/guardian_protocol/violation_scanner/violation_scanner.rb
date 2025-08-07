# seryn/guardian_protocol/violation_scanner/violation_scanner.rb

require_relative 'violation_signature_library'
require_relative 'live_scan_engine'
require_relative 'severity_assessor'
require_relative 'auto_action_dispatcher'
require_relative 'violation_history_log'

module ViolationScanner
  def self.run_scan(context)
    signature = ViolationSignatureLibrary.match(context)
    return unless signature

    severity_data = SeverityAssessor.evaluate(context, signature)
    AutoActionDispatcher.resolve(severity_data)
    ViolationHistoryLog.record(severity_data)

    severity_data
  end
end
