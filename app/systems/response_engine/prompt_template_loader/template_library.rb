# seryn/response_engine/prompt_template_loader/template_library.rb

require 'yaml'

module ResponseEngine
  module PromptTemplateLoader
    module TemplateLibrary
      TEMPLATE_PATH = 'prompts/templates.yml'

      class << self
        def fetch_template(intent:, tone:)
          templates = load_templates
          intent_key = intent.to_s
          tone_key = tone.to_s

          return nil unless templates[intent_key]
          templates[intent_key][tone_key] || templates[intent_key]['neutral']
        rescue => e
          puts "[TemplateLibrary] Error loading template (#{intent}/#{tone}): #{e.message}"
          nil
        end

        private

        def load_templates
          YAML.load_file(TEMPLATE_PATH)
        rescue => e
          puts "[TemplateLibrary] Failed to parse YAML: #{e.message}"
          {}
        end
      end
    end
  end
end
