# 📘 StrategyPhaseMapper — Extracts Active Phase Tasks from Current Strategy
# Subcomponent of LedgerCore::DailyTaskDecomposer

require_relative '../../../strategy_engine/strategy_tracker'

module LedgerCore
  module DailyTaskDecomposer
    module StrategyPhaseMapper
      class << self
        def extract_current_phase
          phase = StrategyEngine::StrategyTracker.current_phase
          return [] unless phase

          phase[:tasks].map do |task|
            {
              title: task[:title],
              block_estimate: task[:time] || estimate_time(task[:title]),
              resources: task[:resources] || [],
              priority: tag_priority(task[:title])
            }
          end
        end

        private

        def estimate_time(task_title)
          case task_title.downcase
          when /email|call|submit/ then :short
          when /review|research/   then :medium
          else :long
          end
        end

        def tag_priority(task_title)
          return :high if task_title.match?(/submit|urgent|final/i)
          return :medium if task_title.match?(/review|update|track/i)
          :low
        end
      end
    end
  end
end
