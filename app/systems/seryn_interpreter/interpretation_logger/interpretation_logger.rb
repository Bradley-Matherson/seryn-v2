# interpretation_logger.rb
# 🧠 Routes interpretation result to all logging modules

require_relative 'interpretation_recorder'
require_relative 'pattern_tracer'
require_relative 'low_confidence_tracker'
require_relative 'mission_anchor_tagger'

module InterpreterSystem
  class InterpretationLogger
    def self.log(result_hash)
      timestamp = Time.now
      result_hash[:timestamp] = timestamp

      # 1. Raw interpretation history (global memory log)
      InterpretationRecorder.record(result_hash, timestamp)

      # 2. Pattern analysis (trending, journaling, mood tracking)
      PatternTracer.trace(result_hash, timestamp)

      # 3. Low confidence flag
      if result_hash[:confidence_score] < 0.60
        LowConfidenceTracker.flag(result_hash, timestamp)
      end

      # 4. Mission alignment tagging
      MissionAnchorTagger.tag(result_hash, timestamp)
    end
  end
end
