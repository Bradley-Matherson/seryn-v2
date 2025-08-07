# 📁 /seryn/strategy_engine/strategy_tracker/realignment_prompt_dispatcher.rb

require_relative 'strategy_registry'
require_relative '../../../context_stack'
require_relative '../../../guardian_protocol'
require_relative '../../../training_system'
require_relative '../../../output_engine'

module RealignmentPromptDispatcher
  class << self
    def trigger_if_needed
      StrategyRegistry.all(:active).each do |strategy|
        event = detect_drift(strategy)
        next unless event

        dispatch_prompt(event) if event[:auto_prompt]
        log_drift(event)
      end
    end

    def detect_drift(strategy)
      drift_type = classify_drift(strategy)
      return nil unless drift_type

      severity = assess_severity(strategy, drift_type)
      return nil if GuardianProtocol.suppresses_prompts?

      {
        strategy_id: strategy[:id],
        drift_type: drift_type,
        severity: severity,
        reason: drift_reason(strategy, drift_type),
        tone: prompt_tone,
        prompt_dispatched: true,
        response_expected: true,
        delivery_channel: :text,
        auto_prompt: severity != :low
      }
    end

    def classify_drift(strategy)
      if strategy[:drift_detected]
        :systemic
      elsif strategy[:progress].to_i < 20 && stale?(strategy)
        :emotional
      elsif role_mismatch?(strategy)
        :misaligned
      else
        nil
      end
    end

    def assess_severity(strategy, type)
      case type
      when :emotional then :moderate
      when :systemic then :critical
      when :misaligned then :moderate
      else :low
      end
    end

    def role_mismatch?(strategy)
      intended_role = strategy[:identity] || :builder
      ContextStack[:identity_role] && ContextStack[:identity_role] != intended_role
    end

    def stale?(strategy)
      last = Time.parse(strategy[:last_used_at] || strategy[:created_at]) rescue return false
      (Time.now - last) / 86_400.0 > 7
    end

    def drift_reason(strategy, type)
      case type
      when :emotional
        "Repeated procrastination or stalled without external cause"
      when :systemic
        "Phase stagnation or unmet unlock condition"
      when :misaligned
        "Strategy conflicts with current identity role"
      else
        "Unknown drift cause"
      end
    end

    def prompt_tone
      role = ContextStack[:identity_role] || :neutral
      case role
      when :builder then "direct + focused"
      when :father  then "compassionate + purpose-linked"
      when :survivor then "stabilizing + gentle"
      else "curious + grounding"
      end
    end

    def dispatch_prompt(event)
      msg = build_prompt_message(event)
      OutputEngine.deliver_soft_prompt(msg, tone: event[:tone])
    end

    def build_prompt_message(event)
      case event[:drift_type]
      when :emotional
        "You’ve skipped this task a few times. Want to talk about what’s getting in the way?"
      when :systemic
        "Your strategy seems stalled at a phase checkpoint. Do you want help unblocking it?"
      when :misaligned
        "Does this still align with the version of you you're becoming?"
      else
        "Need help rerouting this strategy?"
      end
    end

    def log_drift(event)
      TrainingSystem.log_pattern(:strategy_drift, event[:strategy_id])
      File.open("logs/strategy/realignment_events.log", 'a') do |f|
        f.puts "[#{Time.now.iso8601}] #{event[:strategy_id]} - #{event[:drift_type]} - #{event[:severity]}"
      end
    end
  end
end
