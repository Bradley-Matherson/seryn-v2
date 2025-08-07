# core/mission_anchor_store.rb

require_relative "guardian_protocol"

module MissionAnchorStore
  extend self

  # 🔐 Core Pillars (immutable unless Guardian unlocks)
  PURPOSE_PILLARS = [
    :family,
    :legacy,
    :freedom,
    :growth,
    :mastery
  ].freeze

  IDENTITY_ROLES = [
    :father,
    :builder,
    :strategist,
    :provider,
    :student
  ].freeze

  TRAJECTORY_GOALS = [
    {
      id: :credit_optimization,
      description: "Reach 700+ credit score by January",
      deadline: "2026-01-01",
      dependencies: [],
      status: :active,
      priority: :medium
    },
    {
      id: :travel_initiation,
      description: "Begin cross-country travel within 1–2 years",
      deadline: "2026-07-01",
      dependencies: [:financial_stability],
      status: :dormant,
      priority: :long_term
    }
  ].freeze

  # ⛔ Accessors (Read Only unless overridden by Guardian)
  def pillars
    PURPOSE_PILLARS
  end

  def roles
    IDENTITY_ROLES
  end

  def goals
    TRAJECTORY_GOALS
  end

  # 🔒 Lock Check — Prevent unsafe editing
  def locked?
    !GuardianProtocol.override_allowed?(:mission_anchor_store)
  end

  def safe_edit?(caller_id)
    GuardianProtocol.edit_permitted?(caller_id, :mission_anchor_store)
  end

  # 🧭 Goal Access Helpers
  def find_goal(id)
    TRAJECTORY_GOALS.find { |goal| goal[:id] == id }
  end

  def active_goals
    TRAJECTORY_GOALS.select { |g| g[:status] == :active }
  end

  def dormant_goals
    TRAJECTORY_GOALS.select { |g| g[:status] == :dormant }
  end

  def goals_by_priority(level)
    TRAJECTORY_GOALS.select { |g| g[:priority] == level }
  end
end
