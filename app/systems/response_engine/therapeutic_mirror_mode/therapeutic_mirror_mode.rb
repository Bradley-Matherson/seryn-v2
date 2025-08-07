# seryn/response_engine/therapeutic_mirror_mode/therapeutic_mirror_mode.rb

require_relative 'trigger_detector'
require_relative 'reflective_prompt_library'
require_relative 'language_mirror_engine'
require_relative 'spiral_breaker_guide'
require_relative 'self_anchor_reminder'

module ResponseEngine
  module TherapeuticMirrorMode
    module Controller
      class << self
        def reflect(input:, context:)
          return { mirror_mode_active: false } unless TriggerDetector.activate?(input: input, context: context)

          prompt  = ReflectivePromptLibrary.fetch(context: context)
          echo    = LanguageMirrorEngine.echo(input: input, context: context)
          anchor  = SelfAnchorReminder.pull(context: context)
          action  = SpiralBreakerGuide.suggest(context: context)

          {
            mirror_mode_active: true,
            prompt: prompt,
            reflection: echo,
            anchor_used: anchor,
            action_suggested: action
          }
        end
      end
    end
  end
end
