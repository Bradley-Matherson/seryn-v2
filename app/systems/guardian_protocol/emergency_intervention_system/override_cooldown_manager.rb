# seryn/guardian_protocol/emergency_intervention_system/override_cooldown_manager.rb

require 'fileutils'
require 'json'

module OverrideCooldownManager
  COOLDOWN_FILE = "logs/guardian/emergency/cooldowns.json"

  def self.start_timer(severity)
    duration = case severity
               when :low then 6 * 3600
               when :moderate then 24 * 3600
               when :high then 48 * 3600
               when :critical then 72 * 3600
               else 24 * 3600
               end

    cooldowns = load_cooldowns
    cooldowns[:active] = true
    cooldowns[:started_at] = Time.now.to_i
    cooldowns[:duration] = duration

    FileUtils.mkdir_p(File.dirname(COOLDOWN_FILE))
    File.write(COOLDOWN_FILE, JSON.pretty_generate(cooldowns))
  end

  def self.active?
    cooldowns = load_cooldowns
    return false unless cooldowns[:active]

    time_passed = Time.now.to_i - cooldowns[:started_at]
    time_passed < cooldowns[:duration]
  end

  def self.remaining_time
    cooldowns = load_cooldowns
    return 0 unless cooldowns[:active]

    time_left = cooldowns[:duration] - (Time.now.to_i - cooldowns[:started_at])
    [time_left, 0].max
  end

  def self.reset
    File.write(COOLDOWN_FILE, JSON.pretty_generate({ active: false }))
  end

  def self.load_cooldowns
    return { active: false } unless File.exist?(COOLDOWN_FILE)
    JSON.parse(File.read(COOLDOWN_FILE), symbolize_names: true)
  rescue
    { active: false }
  end
end
