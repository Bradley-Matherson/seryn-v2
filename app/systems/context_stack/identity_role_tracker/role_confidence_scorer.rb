# role_confidence_scorer.rb
# 📊 RoleConfidenceScorer — detects active identity role and confidence by live system signals

require_relative "../../ledger_core/ledger_core"          # Task types, focus
require_relative "../../training_system/journal_parser"   # Recent journal entries
require_relative "../../seryn_core/system_registry"       # Active modules
require_relative "../../strategy_engine/strategy_engine"  # Active strategy role

module RoleConfidenceScorer
  @active_role = nil
  @confidence = 0.0
  @reason = ""

  ROLE_PATTERNS = {
    father: [:parenting, :bonding, :family],
    builder: [:creation, :task_build, :project],
    strategist: [:planning, :analysis, :tracking],
    provider: [:work, :income, :money],
    witness: [:journaling, :reflecting],
    survivor: [:recovery, :stress, :minimal],
    creator: [:design, :art, :writing]
  }

  def self.analyze
    scores = Hash.new(0)

    # 1. Pull task patterns from LedgerCore
    recent_tasks = LedgerCore.recent_task_tags(limit: 10)
    recent_tasks.each do |tag|
      ROLE_PATTERNS.each do |role, keywords|
        scores[role] += 1 if keywords.include?(tag)
      end
    end

    # 2. Journal input tone
    tone = JournalParser.detect_tone # => e.g. :reflecting, :anxious, :planning
    ROLE_PATTERNS.each do |role, keywords|
      scores[role] += 2 if keywords.include?(tone)
    end

    # 3. Active module usage
    active_modules = SystemRegistry.currently_active # => [:ledger_core, :strategy_engine, ...]
    scores[:strategist] += 1 if active_modules.include?(:strategy_engine)
    scores[:witness] += 1 if active_modules.include?(:training_system)
    scores[:builder] += 1 if active_modules.include?(:ledger_core)

    # 4. Strategy hints
    if StrategyEngine.current_focus == :long_term_plan
      scores[:strategist] += 2
    end

    # Final decision
    ranked = scores.sort_by { |_r, score| -score }
    @active_role = ranked.first&.first || :strategist
    @confidence = calculate_confidence(ranked)
    @reason = "Top signals: #{ranked.take(2).map { |r, s| "#{r}(#{s})" }.join(', ')}"
  end

  def self.calculate_confidence(ranked_roles)
    top = ranked_roles[0]&.last.to_f
    total = ranked_roles.map(&:last).sum.to_f
    return 0.0 if total.zero?
    (top / total).round(2)
  end

  def self.active_role
    @active_role
  end

  def self.confidence
    @confidence
  end

  def self.reason
    @reason
  end
end
