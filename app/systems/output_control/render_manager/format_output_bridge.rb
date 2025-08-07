# 📁 seryn/systems/output_control/render_manager/format_output_bridge.rb

require_relative "../../output_formatter/output_formatter"
require_relative "../../voice_relay/voice_relay"
require_relative "../channel_dispatcher/channel_dispatcher"

module FormatOutputBridge
  class << self
    def send_to_formatter(sectioned_output, render_type)
      format = determine_format(render_type)

      rendered = OutputFormatter::Controller.format(
        { content: sectioned_output },
        format: format[:output_format],
        theme: :ledger
      )

      # Pass to dispatcher
      ChannelDispatcher::Controller.dispatch({
        type: render_type,
        content: rendered,
        voice_mode: format[:also_voice]
      })

      # Optionally queue voice summary
      if format[:also_voice]
        VoiceRelay::Controller.speak(sectioned_output)
      end
    end

    def format_status
      {
        formatter_ready: true,
        default_theme: :ledger,
        default_format: :markdown
      }
    end

    private

    def determine_format(render_type)
      case render_type
      when :daily_page, :weekly_ledger
        { output_format: :markdown, also_voice: true }
      when :strategy_summary
        { output_format: :pdf, also_voice: false }
      else
        { output_format: :markdown, also_voice: false }
      end
    end
  end
end
