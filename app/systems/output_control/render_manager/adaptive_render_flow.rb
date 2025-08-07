# 📁 seryn/systems/output_control/render_manager/adaptive_render_flow.rb

require_relative "../../../context_stack/context_stack"
require_relative "../../../guardian_protocol/guardian_protocol"

module AdaptiveRenderFlow
  class << self
    def adjust(data)
      data = data.dup

      if ContextStack::Burnout.warning?
        data[:tasks] = data[:tasks].first(2)
        data[:strategy_steps] = []
        data[:reflection_prompt] ||= "What would ease this moment without guilt?"
        data[:tone] = :gentle
      elsif ContextStack::Momentum.spiking?
        data[:tasks] += ["[Stretch] Push toward bonus milestone"]
        data[:reflection_prompt] ||= "What’s one move that makes today feel legendary?"
        data[:tone] = :assertive
      elsif GuardianProtocol::Controller.triggered?(:identity_drift)
        data[:reflection_prompt] ||= "What identity do you feel slipping — and why?"
        data[:tone] = :grounded
      elsif ContextStack::Emotion.crashing?
        data[:tasks] = []
        data[:reflection_prompt] ||= "Let it out. What’s weighing you today?"
        data[:tone] = :calm
      end

      data
    end
  end
end
