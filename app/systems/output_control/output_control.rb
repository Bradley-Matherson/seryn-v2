# 📁 seryn/systems/output_control/output_control.rb

require_relative "output_formatter/output_formatter"
require_relative "channel_dispatcher/channel_dispatcher"
require_relative "voice_relay/voice_relay"
require_relative "render_manager/render_manager"
require_relative "output_archive/output_archive"

module OutputControl
  class << self
    # === Main method to handle output delivery ===
    def deliver(payload)
      formatted = OutputFormatter::Controller.format(payload)
      composite = RenderManager::Controller.compose(formatted)
      dispatched = ChannelDispatcher::Controller.dispatch(composite)

      OutputArchive::Controller.store(composite)

      # Optional voice rendering
      if payload[:voice_mode]
        VoiceRelay::Controller.speak(composite[:voice])
      end

      return dispatched
    end

    # === Diagnostics and system-wide status ===
    def system_status
      {
        last_output: OutputArchive::Controller.last_output_time,
        available_channels: ChannelDispatcher::Controller.available_channels,
        voice_ready: VoiceRelay::Controller.voice_ready?,
        active_formatters: OutputFormatter::Controller.active_templates,
        rendering_health: RenderManager::Controller.render_health
      }
    end
  end
end
