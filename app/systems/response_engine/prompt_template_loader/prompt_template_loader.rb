# seryn/response_engine/prompt_template_loader/prompt_template_loader.rb

require_relative 'template_library'
require_relative 'variable_injector'
require_relative 'tone_variant_selector'
require_relative 'failover_fallback_handler'
require_relative 'delivery_format_router'

require_relative '../response_selector/prompt_framer'

module ResponseEngine
  module PromptTemplateLoader
    module Controller
      class << self
        def load_and_fill(intent:, context:)
          tone = ToneVariantSelector.select_tone(context: context)
          prompt_type = PromptFramer.frame_type(
            classification: context[:classification],
            context: context,
            identity: context[:identity_mode]
          )

          template = TemplateLibrary.fetch_template(intent: intent, tone: tone)

          unless template
            return FailoverFallbackHandler.handle_missing_template(intent: intent, context: context)
          end

          variables = VariableInjector.fill(template: template, context: context)
          formatted_result = DeliveryFormatRouter.format_type(context: context)

          {
            source: :template,
            template_id: "#{intent}_#{tone}".to_sym,
            variables: variables,
            tone: tone,
            prompt_type: prompt_type,
            result: inject(template, variables),
            format: formatted_result
          }
        rescue => e
          FailoverFallbackHandler.handle_template_error(error: e, context: context)
        end

        private

        def inject(template, vars)
          result = template.dup
          vars.each do |key, value|
            result.gsub!("%{#{key}}", value.to_s)
          end
          result
        end
      end
    end
  end
end
