# mission_anchor_tagger.rb
# 🧭 Tags inputs related to core mission pillars (e.g., family, freedom, growth)

require 'fileutils'
require 'json'

module InterpreterSystem
  class MissionAnchorTagger
    MISSION_KEYWORDS = {
      family:    [/dad/, /wife/, /child/, /parent/, /my son/, /my partner/, /father/, /home life/],
      growth:    [/learn/, /improve/, /discipline/, /self[- ]?growth/, /level up/, /master/],
      freedom:   [/independent/, /travel/, /quit my job/, /financial freedom/, /no boss/, /homestead/],
      purpose:   [/legacy/, /calling/, /meaning/, /why am i here/, /fulfillment/, /life path/]
    }

    LOG_FILE = "data/alignment/mission_intents.log"

    def self.tag(result, timestamp)
      tag = detect_alignment(result[:input])
      return unless tag

      FileUtils.mkdir_p(File.dirname(LOG_FILE))

      entry = {
        timestamp: timestamp.iso8601,
        input: result[:input],
        intent: result[:intent],
        mission_alignment: tag,
        confidence: result[:confidence_score],
        routed_to: result[:routed_to]
      }

      File.open(LOG_FILE, 'a') { |f| f.puts entry.to_json }
    rescue => e
      puts "[MissionAnchorTagger::ERROR] #{e.message}"
    end

    def self.detect_alignment(text)
      lower = text.downcase
      MISSION_KEYWORDS.each do |pillar, patterns|
        return pillar if patterns.any? { |p| lower.match?(p) }
      end
      nil
    end
  end
end
