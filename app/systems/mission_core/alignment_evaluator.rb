# core/alignment_evaluator.rb

require_relative "mission_anchor_store"
require_relative "guardian_protocol"

module AlignmentEvaluator
  extend self

  def evaluate(action_signature:, context: {})
    anchors = fetch_anchors
    summary = analyze_signature(action_signature)

    matched = anchors[:pillars].select { |pillar| summary[:tags].include?(pillar) }
    violated = anchors[:pillars] - matched

    score = calculate_score(matched, violated)
    priority_match = match_priority(summary[:tags], anchors[:goals])
    active_identity = context[:identity] || infer_identity(summary[:source])

    result = {
      alignment_score: score,
      allowed: score >= 0.75,
      active_identity: active_identity,
      mission_match: violated.empty?,
      conflict_pillars: violated,
      dominant_pillars: matched,
      correction_needed: score < 0.5
    }

    flag_if_violation(result, action_signature)
    result
  end

  private

  def fetch_anchors
    {
      pillars: MissionAnchorStore.pillars,
      roles: MissionAnchorStore.roles,
      goals: MissionAnchorStore.goals
    }
  end

  def analyze_signature(signature)
    # Example: { tags: [:freedom, :growth], source: :strategy_engine }
    signature
  end

  def calculate_score(matched, violated)
    total = matched.length + violated.length
    return 0.0 if total.zero?
    (matched.length.to_f / total).round(2)
  end

  def match_priority(tags, goals)
    tags.each do |tag|
      match = goals.find { |g| g[:id] == tag || g[:description].downcase.include?(tag.to_s) }
      return match[:id] if match
    end
    nil
  end

  def infer_identity(source)
    case source
    when :ledger_core then :builder
    when :response_engine then :strategist
    else :unknown
    end
  end

  def flag_if_violation(result, action_signature)
    if !result[:allowed] || result[:correction_needed]
      GuardianProtocol.flag_violation!(
        source: :alignment_evaluator,
        signature: action_signature,
        result: result
      )
    end
  end
end
