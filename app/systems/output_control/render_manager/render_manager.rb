# 📁 seryn/systems/output_control/render_manager/render_manager.rb

require_relative "render_template_selector"
require_relative "data_stitcher"
require_relative "section_assembler"
require_relative "format_output_bridge"
require_relative "adaptive_render_flow"

module RenderManager
  module Controller
    class << self
      def compose(payload = {})
        # Step 1: Select template type
        render_type = RenderTemplateSelector.determine(payload)

        # Step 2: Pull and merge relevant data
        stitched_data = DataStitcher.build_context(render_type)

        # Step 3: Adapt render dynamically based on state
        adjusted_data = AdaptiveRenderFlow.adjust(stitched_data)

        # Step 4: Assemble visual section layout
        sectioned_output = SectionAssembler.build(adjusted_data)

        # Step 5: Format for OutputFormatter
        FormatOutputBridge.send_to_formatter(sectioned_output, render_type)
      end

      def render_debug_summary
        {
          available_templates: RenderTemplateSelector.templates,
          current_energy: ContextStack::Energy.current_level,
          current_role: LedgerCore::Identity.active,
          burnout: ContextStack::Burnout.warning?,
          voice_ready: VoiceRelay::Controller.voice_ready?
        }
      end

      def render_health
        FormatOutputBridge.format_status
      end
    end
  end
end
