# 📁 /seryn/strategy_engine/constraint_analyzer/obligation_clash_detector.rb

require_relative '../../../ledger_core'
require_relative '../../../mission_core'
require_relative '../../../context_stack'
require_relative '../../../guardian_protocol'

module ObligationClashDetector
  class << self
    def detect
      deadline_conflict = active_deadlines?
      mission_locked     = MissionCore.focus_window_locked?
      life_phase_blocked = life_phase_block?
      guardian_hold      = GuardianProtocol.execution_block_active?

      conflict = deadline_conflict || mission_locked || life_phase_blocked || guardian_hold

      {
        conflict_detected: conflict,
        blocked: conflict,
        warnings: summary(deadline_conflict, mission_locked, life_phase_blocked, guardian_hold)
      }
    end

    def active_deadlines?
      LedgerCore.upcoming_deadlines.any? { |d| d[:urgency] == :high || d[:due_within] <= 3 }
    end

    def life_phase_block?
      [:travel, :transition, :recovery].include?(ContextStack[:life_phase])
    end

    def summary(*flags)
      reasons = []
      reasons << "High-priority deadline approaching" if flags[0]
      reasons << "MissionCore has focus lock active" if flags[1]
      reasons << "Life phase unsuitable for strategy execution" if flags[2]
      reasons << "Guardian has temporarily blocked new strategy creation" if flags[3]
      reasons.empty? ? nil : reasons
    end
  end
end
