# 📁 seryn/systems/output_control/render_manager/render_template_selector.rb

require_relative "../../../context_stack/context_stack"
require_relative "../../../guardian_protocol/guardian_protocol"

module RenderTemplateSelector
  TEMPLATES = [
    :daily_page,
    :weekly_ledger,
    :strategy_summary,
    :reflection_mode_output,
    :alignment_report
  ]

  class << self
    def determine(payload = {})
      override = payload[:force_template]
      return override.to_sym if override && TEMPLATES.include?(override.to_sym)

      return :reflection_mode_output if silent_mode? || recovering?
      return :strategy_summary if ContextStack::Energy.peak?
      return :alignment_report if GuardianProtocol::Controller.triggered?(:identity_drift)

      :daily_page
    end

    def templates
      TEMPLATES
    end

    private

    def silent_mode?
      ContextStack::Settings.silent_mode? rescue false
    end

    def recovering?
      ContextStack::Burnout.active? || ContextStack::Emotion.crashing?
    rescue
      false
    end
  end
end
