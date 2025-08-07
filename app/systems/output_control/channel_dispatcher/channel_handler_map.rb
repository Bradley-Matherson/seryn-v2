# 📁 seryn/systems/output_control/channel_dispatcher/channel_handler_map.rb

require_relative "handlers/terminal_handler"
require_relative "handlers/pdf_exporter"
require_relative "handlers/html_renderer"
require_relative "handlers/voice_dispatch"
require_relative "handlers/push_notifier"

module ChannelDispatcher
  module ChannelHandlerMap
    HANDLERS = {
      terminal: TerminalHandler,
      pdf: PDFExporter,
      html: HTMLRenderer,
      voice: VoiceDispatch,
      push: PushNotifier,
      log_only: nil
    }

    class << self
      def handler_for(channel)
        HANDLERS[channel.to_sym]
      end

      def available
        HANDLERS.keys.reject { |key| HANDLERS[key].nil? }
      end
    end
  end
end
