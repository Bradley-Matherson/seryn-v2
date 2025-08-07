# 📁 seryn/systems/output_control/render_manager/section_assembler.rb

require_relative "../../../guardian_protocol/guardian_protocol"

module SectionAssembler
  class << self
    def build(data)
      layout = []

      layout << section_header("🧭 Today’s Mission: #{data[:identity_role].to_s.capitalize} Mode Active")

      if data[:burnout] == :high
        layout << alert_block("⚠️ Burnout Risk High — reduce task load and reset rhythm.")
      end

      layout << task_section(data[:tasks]) if data[:tasks]&.any?

      layout << streak_tracker(data[:streak])
      layout << strategy_focus(data[:strategy_focus], data[:strategy_steps])
      layout << reflection_prompt(data[:reflection_prompt])
      layout << summary_footer(data)

      layout.compact.join("\n\n")
    end

    private

    def section_header(title)
      "## #{title}"
    end

    def alert_block(message)
      "### 🚨 Alert\n#{message}"
    end

    def task_section(tasks)
      task_list = tasks.map { |t| "- [ ] #{t}" }.join("\n")
      "### ✅ Top Tasks\n#{task_list}"
    end

    def streak_tracker(count)
      "### 🔁 Streak Tracker\nStreak: #{count} days"
    end

    def strategy_focus(focus, steps)
      return nil unless focus && steps
      step_lines = steps.map { |s| "- [ ] #{s}" }.join("\n")
      "### 🎯 Strategy Phase: #{focus}\n#{step_lines}"
    end

    def reflection_prompt(prompt)
      return nil unless prompt
      "### 💬 Reflection Prompt\n_#{prompt}_"
    end

    def summary_footer(data)
      "🧠 Tone: #{data[:tone].to_s.capitalize} | Energy: #{data[:energy]} | Mood: #{data[:mood].to_s.capitalize}"
    end
  end
end
