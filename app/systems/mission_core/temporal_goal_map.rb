# core/temporal_goal_map.rb

require "date"
require_relative "mission_anchor_store"
require_relative "guardian_protocol"

module TemporalGoalMap
  extend self

  GOAL_FILE = "data/temporal_goals.json"

  def all_goals
    file_goals + static_goals
  end

  def active_goals
    all_goals.select { |g| g["status"].to_sym == :active }
  end

  def dormant_goals
    all_goals.select { |g| g["status"].to_sym == :dormant }
  end

  def find_goal(id)
    all_goals.find { |g| g["id"].to_sym == id.to_sym }
  end

  def update_status(id, new_status)
    return false unless GuardianProtocol.override_allowed?(:temporal_goal_map)
    goals = file_goals
    goal = goals.find { |g| g["id"].to_sym == id.to_sym }
    return false unless goal

    goal["status"] = new_status.to_s
    save_goals(goals)
    true
  end

  def add_goal(goal_hash)
    return false unless GuardianProtocol.edit_permitted?(:system, :temporal_goal_map)
    goals = file_goals
    goals << goal_hash
    save_goals(goals)
    true
  end

  def check_dependencies(goal_id)
    goal = find_goal(goal_id)
    return [] unless goal && goal["dependencies"]

    goal["dependencies"].map(&:to_sym).reject do |dep_id|
      dep_goal = find_goal(dep_id)
      dep_goal && dep_goal["status"] == "achieved"
    end
  end

  def urgency_sorted
    active_goals.sort_by do |g|
      deadline = g["deadline"] ? Date.parse(g["deadline"]) : Date.today + 999
      [g["priority"].to_s, deadline]
    end
  end

  private

  def static_goals
    # Pull frozen/default goals from anchor store
    MissionAnchorStore.goals.map do |g|
      {
        "id" => g[:id].to_s,
        "description" => g[:description],
        "deadline" => g[:deadline],
        "status" => g[:status].to_s,
        "priority" => g[:priority].to_s,
        "dependencies" => (g[:dependencies] || []).map(&:to_s)
      }
    end
  end

  def file_goals
    return [] unless File.exist?(GOAL_FILE)
    JSON.parse(File.read(GOAL_FILE))
  rescue
    []
  end

  def save_goals(goals)
    File.write(GOAL_FILE, JSON.pretty_generate(goals))
  rescue => e
    puts "[TemporalGoalMap] Save error: #{e.message}"
  end
end
