# seryn/response_engine/response_selector/response_selector.rb

require_relative 'input_category_classifier'
require_relative 'tone_router'
require_relative 'response_mode_chooser'
require_relative 'persona_mirror_interface'
require_relative 'output_instruction_dispatcher'

# New subsystem hooks
require_relative '../tone_modulator'
require_relative '../prompt_framer'

require_relative '../../context/context_stack'
require_relative '../../training/training_system'
require_relative '../../mission/mission_core'
require_relative '../../guardian/guardian_protocol'

module ResponseEngine
  module ResponseSelector
    class Controller
      def self.select(input:)
        context = ContextStack.snapshot

        # Step 1: Classify intent + tone
        classification = InputCategoryClassifier.classify(input: input, context: context)

        # Step 2: Determine modulated tone
        tone = ToneModulator.determine(
          classification: classification,
          context: context
        )

        # Step 3: Determine identity persona
        persona = PersonaMirrorInterface.active_identity(context)

        # Step 4: Choose prompt structure type (reflection, mirror, etc.)
        prompt_type = PromptFramer.frame_type(
          classification: classification,
          context: context,
          identity: persona[:identity]
        )

        # Step 5: Choose response mode (template, LLM, mirror)
        mode = ResponseModeChooser.choose(
          classification: classification,
          context: context
        )

        # Step 6: Package response metadata
        instruction = {
          type: classification[:type],
          tone: tone,
          mode: mode,
          prompt_type: prompt_type,
          voice: persona[:tone_signature],
          delivery: persona[:delivery_method] || :text
        }

        # Step 7: Dispatch to response engine
        OutputInstructionDispatcher.dispatch(
          instruction: instruction,
          input: input,
          context: context
        )
      end
    end
  end
end
