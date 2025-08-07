# 📁 seryn/systems/output_control/channel_dispatcher/handlers/html_renderer.rb

require "fileutils"
require "time"
require "securerandom"

module HTMLRenderer
  OUTPUT_DIR = "outputs/html"

  def self.call(content)
    timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    file_id = SecureRandom.hex(3)
    folder = File.join(OUTPUT_DIR, Time.now.strftime("%Y-%m-%d"))
    FileUtils.mkdir_p(folder)

    path = File.join(folder, "seryn_output_#{timestamp}_#{file_id}.html")

    begin
      File.write(path, wrap_html(content))
      puts "🌐 HTML output saved: #{path}"
    rescue => e
      puts "❌ Failed to render HTML: #{e.message}"
    end
  end

  def self.wrap_html(body)
    <<~HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Seryn Output</title>
      <style>
        body { font-family: 'Roboto', sans-serif; padding: 2em; background: #f4f4f4; }
        h2, h3 { color: #333; }
        li { margin-bottom: 0.5em; }
      </style>
    </head>
    <body>
      #{body}
    </body>
    </html>
    HTML
  end
end
