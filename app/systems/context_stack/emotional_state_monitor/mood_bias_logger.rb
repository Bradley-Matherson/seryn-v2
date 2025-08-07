# mood_bias_logger.rb
# 🪞 MoodBiasLogger — logs long-term emotional skew and detects dominant bias

require 'yaml'
require 'fileutils'

module MoodBiasLogger
  HISTORY_PATH = "data/context_stack/emotion_history.yml"
  @bias_window = 40  # Number of emotional snapshots to consider
  @negative_bias_threshold = 0.65

  NEGATIVE_EMOTIONS = [:drained, :stuck, :empty, :spiraling, :chaotic, :numb]
  POSITIVE_EMOTIONS = [:focused, :hopeful, :calm, :sharp, :grateful]

  def self.log(current_emotion)
    # Called during each emotion cycle to allow historical bias accumulation
    append_to_history(current_emotion)
  end

  def self.append_to_history(emotion)
    FileUtils.mkdir_p("data/context_stack")
    history = load
    history << { timestamp: Time.now, emotion: emotion.to_sym }
    history.shift while history.size > @bias_window
    File.write(HISTORY_PATH, history.to_yaml)
  end

  def self.load
    return [] unless File.exist?(HISTORY_PATH)
    YAML.load_file(HISTORY_PATH) || []
  end

  def self.skew_negative?
    history = load.last(@bias_window)
    total = history.size
    negative = history.count { |e| NEGATIVE_EMOTIONS.include?(e[:emotion]) }
    return false if total.zero?
    (negative.to_f / total.to_f) >= @negative_bias_threshold
  end

  def self.bias_report
    history = load.last(@bias_window)
    {
      total_entries: history.size,
      negative_ratio: (history.count { |e| NEGATIVE_EMOTIONS.include?(e[:emotion]) }).fdiv(history.size).round(2),
      most_common: history.tally { |e| e[:emotion] }.max_by { |_, v| v }&.first
    }
  end
end
