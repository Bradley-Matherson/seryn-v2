# frozen_string_literal: true

# 🪨 EmotionalAnchorLibrary
# Purpose:
# Builds and maintains a library of emotionally stabilizing content —
# including quotes, journaling insights, goal affirmations, and grounding phrases.
# These anchors are used during spirals, motivation dips, or reset moments.

require 'json'
require 'fileutils'

module TrainingSystem
  module UserBehaviorProfiler
    module EmotionalAnchorLibrary
      ANCHOR_FILE = "data/emotional_anchors.json"

      def self.fetch_active_anchors
        load_anchors.last(5)
      end

      def self.store_anchor(type:, content:, source: :reflection)
        anchors = load_anchors
        anchors << {
          type: type,
          content: content,
          source: source,
          timestamp: Time.now
        }

        save_anchors(anchors)
      end

      def self.load_anchors
        File.exist?(ANCHOR_FILE) ? JSON.parse(File.read(ANCHOR_FILE), symbolize_names: true) : []
      end

      def self.save_anchors(anchors)
        FileUtils.mkdir_p(File.dirname(ANCHOR_FILE))
        File.write(ANCHOR_FILE, JSON.pretty_generate(anchors))
      end

      def self.search_by_type(type)
        load_anchors.select { |a| a[:type].to_sym == type.to_sym }
      end

      def self.random_quote_anchor
        anchors = search_by_type(:quote)
        return nil if anchors.empty?

        anchors.sample[:content]
      end
    end
  end
end
