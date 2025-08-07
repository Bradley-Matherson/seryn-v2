# 📁 seryn/systems/output_control/channel_dispatcher/handlers/pdf_exporter.rb

require "fileutils"
require "time"
require "securerandom"
require "tempfile"

module PDFExporter
  OUTPUT_DIR = "outputs/pdf"

  def self.call(content)
    timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    file_id = SecureRandom.hex(4)
    folder = File.join(OUTPUT_DIR, Time.now.strftime("%Y-%m-%d"))
    FileUtils.mkdir_p(folder)

    html_file = Tempfile.new(["seryn_output", ".html"])
    pdf_path = File.join(folder, "output_#{timestamp}_#{file_id}.pdf")

    begin
      html_file.write(content)
      html_file.close
      system("wkhtmltopdf #{html_file.path} #{pdf_path}")
      puts "📄 PDF saved: #{pdf_path}"
    rescue => e
      puts "❌ PDF generation failed: #{e.message}"
    ensure
      html_file.unlink
    end
  end
end
