# 📁 seryn/systems/output_control/output_formatter/structure_composer.rb

module OutputFormatter
  module StructureComposer
    TEMPLATES = {
      daily_page: <<~TEMPLATE,
        ## 🧭 Today’s Focus: <%= focus %>
        ### 🗂️ Identity Role: <%= identity_role.capitalize %>

        ### ✅ Primary Tasks:
        <% tasks.each do |task| %>
        - [ ] <%= task %>
        <% end %>

        💬 **Reflection Prompt:**  
        "<%= reflection %>"

        📈 Streak: <%= streak_count %> days  
        🎧 Voice Mode: <%= voice_mode.capitalize %>
      TEMPLATE

      strategy_summary: <<~TEMPLATE,
        ## 📊 Strategy Summary — <%= date %>
        ### 🎯 Current Goal Phase: <%= goal_phase %>

        **Steps in Progress:**
        <% steps.each do |step| %>
        - [ ] <%= step %>
        <% end %>

        **Momentum Notes:**  
        <%= momentum_notes %>
      TEMPLATE

      alignment_log: <<~TEMPLATE,
        ## 🧠 Alignment Log — <%= date %>
        - Role: <%= identity_role %>
        - Emotion: <%= emotion_state %>
        - Reflection: "<%= reflection %>"
        - Drift: <%= drift_detected ? "⚠️ Yes" : "✅ No" %>
      TEMPLATE
    }

    class << self
      def compose(payload)
        template_type = payload[:template] || :daily_page
        template = TEMPLATES[template_type]

        raise "Unknown template type: #{template_type}" unless template

        ERB.new(template, trim_mode: "-").result_with_hash(payload)
      end

      def available_templates
        TEMPLATES.keys
      end
    end
  end
end
