# frozen_string_literal: true

# 🎛️ ResponseRemixer
# Purpose:
# Refreshes Seryn’s language when prompts become repetitive or stale.
# Creates novel phrasing variants based on user growth, context, and tone evolution.

require 'digest'

module TrainingSystem
  module VoiceTrainer
    module ResponseRemixer
      VARIANT_LIBRARY = {
        soft_prompt: [
          "Have you considered…",
          "What would happen if you gently explored…",
          "Would it help to pause and notice…"
        ],
        strategic_nudge: [
          "Let's break this down into one smart move.",
          "Which lever would give you the biggest shift right now?",
          "What’s the smallest decision that moves this forward?"
        ],
        momentum_boost: [
          "You’ve got this — want to surge now or steady pace?",
          "Let’s ride the clarity — what’s next?",
          "Strike while you're sharp. Execute on instinct."
        ],
        reflective_mode: [
          "What does your grounded self know here?",
          "If this showed up again next week, what would you do differently?",
          "What truth are you resisting that might help?"
        ]
      }

      def self.adapt_prompt(original_prompt)
        style = classify_prompt(original_prompt)
        return original_prompt unless VARIANT_LIBRARY[style]

        pool = VARIANT_LIBRARY[style]
        remix = pool.sample
        remix += " #remix" if similar_phrase_used?(remix)

        remix
      end

      def self.classify_prompt(text)
        if text.include?("consider") || text.include?("pause")
          :soft_prompt
        elsif text.include?("leverage") || text.include?("move forward")
          :strategic_nudge
        elsif text.include?("clarity") || text.include?("momentum")
          :momentum_boost
        elsif text.include?("resist") || text.include?("truth") || text.include?("reflection")
          :reflective_mode
        else
          :soft_prompt
        end
      end

      def self.similar_phrase_used?(phrase)
        hash = Digest::SHA256.hexdigest(phrase)
        recent_hashes = load_used_hashes

        if recent_hashes.include?(hash)
          true
        else
          store_phrase_hash(hash)
          false
        end
      end

      def self.load_used_hashes
        path = "data/prompt_variant_history.json"
        return [] unless File.exist?(path)
        JSON.parse(File.read(path))
      end

      def self.store_phrase_hash(hash)
        path = "data/prompt_variant_history.json"
        history = File.exist?(path) ? JSON.parse(File.read(path)) : []
        history << hash
        history = history.last(50) # Keep history short
        File.write(path, JSON.pretty_generate(history))
      end
    end
  end
end
