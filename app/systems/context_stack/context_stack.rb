# context_stack.rb
# 🔁 Central system controller for ContextStack
# Tracks and synchronizes: identity role, emotional state, environment, system activity, momentum

require_relative "identity_role_tracker/identity_role_tracker"
require_relative "emotional_state_monitor/emotional_state_monitor"
require_relative "environmental_awareness_module/environmental_awareness_module"
require_relative "system_activity_feed/system_activity_feed"
require_relative "momentum_pulse_calculator/momentum_pulse_calculator"

require 'yaml'
require 'fileutils'

module ContextStack
  STATE_FILE = "data/context_stack/current_state.yml"
  LOG_DIR    = "logs/context/"

  def self.current_state
    @current_state ||= {
      identity_role: nil,
      identity_confidence: 0.0,
      emotion: nil,
      spiral_risk: :unknown,
      system_focus: nil,
      momentum: 0.0,
      anchor: nil,
      reflection_window: false,
      timestamp: Time.now
    }
  end

  def self.refresh
    current_state[:identity_role], current_state[:identity_confidence] = IdentityRoleTracker.current_role
    current_state[:emotion], current_state[:spiral_risk] = EmotionalStateMonitor.read_emotion
    current_state[:environment] = EnvironmentalAwarenessModule.snapshot
    current_state[:system_focus] = SystemActivityFeed.current_focus
    current_state[:momentum] = MomentumPulseCalculator.calculate_momentum
    current_state[:anchor] = IdentityRoleTracker.current_anchor
    current_state[:reflection_window] = EmotionalStateMonitor.reflection_window_open?
    current_state[:timestamp] = Time.now

    write_current_state
    log_historical_context
  end

  def self.write_current_state
    FileUtils.mkdir_p("data/context_stack")
    File.write(STATE_FILE, current_state.to_yaml)
  end

  def self.log_historical_context
    week = Time.now.strftime("%G-W%V")
    FileUtils.mkdir_p("#{LOG_DIR}")
    File.open("#{LOG_DIR}#{week}.yml", "a") do |file|
      file.puts current_state.to_yaml
      file.puts "---"
    end
  end

  def self.get
    current_state
  end
end
