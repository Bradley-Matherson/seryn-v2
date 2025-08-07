# recovery_window_forecaster.rb
# 📅 RecoveryWindowForecaster — predicts dips in momentum and recommends soft-day pacing

require 'yaml'
require 'time'

module RecoveryWindowForecaster
  LOG_PATH = "logs/context/momentum_cycles.yml"
  @projected_dip_days = nil

  def self.predict
    history = load_history.last(7) # Last 7 days
    return unless history.any?

    low_scores = history.count { |e| e[:score] < 1.5 }
    burnout_flags = history.count { |e| e[:burnout] }

    # Simple projection logic
    if burnout_flags >= 2 || low_scores >= 3
      @projected_dip_days = 0 # Immediate dip expected
    elsif history.last[:trend] == :falling
      @projected_dip_days = 1
    else
      @projected_dip_days = 2
    end
  end

  def self.projected_dip
    @projected_dip_days || "unknown"
  end

  def self.load_history
    return [] unless File.exist?(LOG_PATH)
    YAML.load_file(LOG_PATH) || []
  end
end
