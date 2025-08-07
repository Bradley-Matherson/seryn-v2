# 📁 core/seryn_context_stack.rb

module SerynContextStack
  @context = {
    active_goal: nil,
    current_energy: :unknown,
    identity_mode: nil,
    focus_pillar: nil,
    today_main_task: nil,
    last_journaling_marker: nil,
    last_input: nil,
    last_response: nil
  }

  class << self
    def refresh_context
      # Placeholder for external system pulls (e.g. LedgerCore, TrainingSystem)
      # This is where automatic updates from subsystems would be pulled in
      puts "[ContextStack] Context refreshed."
    end

    def update(key, value)
      return unless @context.key?(key)
      @context[key] = value
      puts "[ContextStack] Updated: #{key} → #{value}"
    end

    def get(key)
      @context[key]
    end

    def snapshot
      @context.dup
    end

    def load_snapshot(data)
      @context.merge!(data)
      puts "[ContextStack] Snapshot loaded."
    end

    def reset
      @context.each_key { |k| @context[k] = nil }
      puts "[ContextStack] Context reset."
    end
  end
end
