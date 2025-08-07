# 📁 seryn/systems/output_control/output_formatter/format_switcher.rb

require "json"
require "yaml"
require "erb"
require "tempfile"

module OutputFormatter
  module FormatSwitcher
    class << self
      def convert(format, data:)
        case format.to_sym
        when :markdown
          to_markdown(data)
        when :html
          to_html(data)
        when :pdf
          to_pdf(to_html(data)) # Generate HTML first, then convert
        when :json
          data.to_json
        when :yaml
          data.to_yaml
        else
          raise "Unsupported format: #{format}"
        end
      end

      private

      def to_markdown(content)
        # If already markdown-styled, return as-is
        content
      end

      def to_html(markdown)
        # Very basic Markdown to HTML converter for now
        html = markdown.dup
        html.gsub!(/^## (.+)$/, '<h2>\1</h2>')
        html.gsub!(/^### (.+)$/, '<h3>\1</h3>')
        html.gsub!(/^- \[ \] (.+)$/, '<li><input type="checkbox"> \1</li>')
        html.gsub!(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
        html.gsub!(/\*(.+?)\*/, '<em>\1</em>')
        html.gsub!(/\n/, "<br>\n")
        "<html><body>#{html}</body></html>"
      end

      def to_pdf(html_content)
        # Simulate PDF rendering by writing to a .pdf file.
        # In production, use wkhtmltopdf or PDFKit.
        pdf_path = "/tmp/output_#{Time.now.to_i}.pdf"
        html_file = Tempfile.new(["output", ".html"])
        html_file.write(html_content)
        html_file.close

        system("wkhtmltopdf #{html_file.path} #{pdf_path}")

        File.read(pdf_path)
      rescue => e
        "PDF generation failed: #{e.message}"
      ensure
        html_file.unlink if html_file
      end
    end
  end
end
