# 📁 seryn/systems/output_control/channel_dispatcher/handlers/terminal_handler.rb

module TerminalHandler
  def self.call(content)
    puts "\n" + ("=" * 40)
    puts "🖥️  Terminal Output from Seryn:"
    puts "-" * 40
    puts content
    puts "=" * 40 + "\n"
  end
end
