# 📁 seryn/systems/output_control/output_archive/output_archive.rb

require_relative "daily_output_logger"
require_relative "voice_transcript_saver"
require_relative "strategy_snapshot_logger"
require_relative "reflective_memory_cache"
require_relative "archival_purge_manager"

module OutputArchive
  module Controller
    class << self
      def store(output)
        DailyOutputLogger.log(output)

        if output[:type] == :strategy_summary
          StrategySnapshotLogger.save_snapshot(output)
        elsif output[:type] == :reflection_mode_output
          ReflectiveMemoryCache.store_reflection(output)
        end

        if output[:voice_mode]
          VoiceTranscriptSaver.save_voice(output)
        end
      end

      def last_output_time
        DailyOutputLogger.last_logged_at
      end

      def cleanup
        ArchivalPurgeManager.purge_according_to_rules
      end
    end
  end
end
