# mode_duration_timer.rb
# ⏱️ Subcomponent: ModeDurationTimer — tracks how long current identity role has been active

require 'time'

module ModeDurationTimer
  @activation_time = Time.now

  def self.reset_timer
    @activation_time = Time.now
  end

  def self.seconds_active
    Time.now - @activation_time
  end

  def self.duration_string
    total_seconds = seconds_active
    hours = (total_seconds / 3600).to_i
    minutes = ((total_seconds % 3600) / 60).to_i
    "#{hours}h #{minutes}m"
  end
end
