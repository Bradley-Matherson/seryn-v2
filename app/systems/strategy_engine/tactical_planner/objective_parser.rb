# 📁 core/strategy/tactical_planner/objective_parser.rb

module ObjectiveParser
  class << self
    def parse(raw_prompt)
      goal = extract_goal(raw_prompt)
      timeline = extract_timeline(raw_prompt)
      tags = detect_tags(raw_prompt)

      structure_output(goal, timeline, tags)
    end

    def extract_goal(raw)
      # Simplified placeholder logic
      raw.strip.gsub(/^(help me|i need to|i want to)/i, '').strip
    end

    def extract_timeline(raw)
      # Detect time windows or urgency cues
      if raw.downcase.include?("by december")
        { start: Time.now, end: Time.new(Time.now.year, 12, 1) }
      elsif raw.downcase.include?("in 2 months")
        { start: Time.now, end: Time.now + (60 * 60 * 24 * 60) }
      else
        nil
      end
    end

    def detect_tags(raw)
      tags = []
      tags << :finance if raw.downcase =~ /credit|budget|income|macbook|money/
      tags << :logistics if raw.downcase.include?("travel") || raw.downcase.include?("truck")
      tags << :learning if raw.downcase.include?("learn") || raw.downcase.include?("code")
      tags.uniq
    end

    def structure_output(goal, timeline, tags)
      {
        description: goal,
        timeline: timeline,
        tags: tags
      }
    end
  end
end
