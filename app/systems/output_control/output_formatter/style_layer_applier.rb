# 📁 seryn/systems/output_control/output_formatter/style_layer_applier.rb

module OutputFormatter
  module StyleLayerApplier
    THEMES = {
      minimal: {
        font: "Monospace",
        accent: "",
        header_prefix: "## ",
        spacing: "\n"
      },
      ledger: {
        font: "Roboto",
        accent: "🔵",
        header_prefix: "## ",
        spacing: "\n\n"
      },
      tactical: {
        font: "Impact",
        accent: "⚔️",
        header_prefix: "## ",
        spacing: "\n"
      },
      calm: {
        font: "Serif",
        accent: "🌿",
        header_prefix: "## ",
        spacing: "\n\n"
      }
    }

    class << self
      def apply(content, theme: :ledger)
        style = THEMES[theme] || THEMES[:minimal]

        # Basic visual signature application
        styled_content = content
          .gsub(/^## (.*)$/) { "#{style[:header_prefix]}#{style[:accent]} #{$1}" }
          .gsub("\n\n", style[:spacing])

        inject_font_comment(styled_content, style[:font])
      end

      private

      def inject_font_comment(content, font_name)
        # Adds a comment tag showing which font to use for PDF/HTML generators
        <<~OUT
        <!-- Font: #{font_name} -->
        #{content}
        OUT
      end
    end
  end
end
