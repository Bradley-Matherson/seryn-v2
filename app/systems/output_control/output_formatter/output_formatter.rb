# 📁 seryn/systems/output_control/output_formatter/output_formatter.rb

require_relative "structure_composer"
require_relative "style_layer_applier"
require_relative "content_sanitizer"
require_relative "format_switcher"
require_relative "placeholder_resolver"

module OutputFormatter
  module Controller
    class << self
      def format(payload, format: :markdown, theme: :ledger)
        clean = ContentSanitizer.clean(payload)
        structured = StructureComposer.compose(clean)
        resolved = PlaceholderResolver.resolve(structured)
        styled = StyleLayerApplier.apply(resolved, theme: theme)
        final_output = FormatSwitcher.convert(format, data: styled)

        final_output
      end

      def active_templates
        StructureComposer.available_templates
      end
    end
  end
end
