# emotion_classifier.rb
# 🧠 EmotionClassifier — analyzes emotional tone from journal and task inputs

require_relative "../../training_system/journal_parser"
require_relative "../../ledger_core/ledger_core"

module EmotionClassifier
  EMOTION_MAP = {
    lost: :drained,
    tired: :drained,
    stuck: :stuck,
    sharp: :focused,
    planning: :focused,
    grateful: :hopeful,
    numb: :empty,
    spiraling: :spiraling,
    anxious: :chaotic,
    peaceful: :calm,
    overwhelmed: :chaotic,
    intentional: :sharp
  }

  @primary = :unknown
  @secondary = nil
  @confidence = 0.0

  def self.analyze
    tone_tags = JournalParser.detect_emotional_tags # e.g., [:tired, :lost, :planning]
    task_tags = LedgerCore.recent_task_tags(limit: 8)

    emotion_vector = (tone_tags + task_tags).map { |tag| EMOTION_MAP[tag] }.compact

    tallied = emotion_vector.tally
    sorted = tallied.sort_by { |_e, count| -count }

    @primary = sorted[0]&.first || :neutral
    @secondary = sorted[1]&.first
    @confidence = calculate_confidence(sorted)
  end

  def self.calculate_confidence(sorted_emotions)
    return 0.0 if sorted_emotions.empty?
    top_count = sorted_emotions[0][1].to_f
    total = sorted_emotions.map(&:last).sum.to_f
    (top_count / total).round(2)
  end

  def self.primary
    @primary
  end

  def self.secondary
    @secondary
  end

  def self.confidence
    @confidence
  end

  def self.vector
    {
      primary: @primary,
      secondary: @secondary,
      confidence: @confidence
    }
  end
end
