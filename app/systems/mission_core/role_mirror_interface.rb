# core/role_mirror_interface.rb

require_relative "mission_anchor_store"

module RoleMirrorInterface
  extend self

  # Reflects current role and shifts Seryn's tone or advice style accordingly
  def reflect_active_role(user_context)
    role = determine_role(user_context)
    tone = tone_for(role)

    {
      role: role,
      tone: tone,
      message_style: style_for(role)
    }
  end

  # Suggests a role shift if user's intent or context is out of sync with declared identity
  def suggest_role_shift_if_needed(intent_hash)
    declared_roles = MissionAnchorStore.roles
    current_role = intent_hash[:identity]
    return nil if declared_roles.include?(current_role)

    {
      suggestion: "Identity drift detected",
      message: "This doesn't reflect the roles you've declared. Would shifting into Builder or Father mode serve you better?"
    }
  end

  # Simple textual reflection method
  def echo_role_back(tone: :encouraging)
    case tone
    when :encouraging
      "You’re stepping into this as the #{current_active_role.to_s.capitalize} — keep building forward."
    when :grounding
      "Breathe. Return to your role as #{current_active_role.to_s.capitalize}."
    when :strategic
      "Approach this like a Strategist would. What’s the highest-leverage move?"
    else
      "You're operating as #{current_active_role.to_s.capitalize}. Stay anchored."
    end
  end

  private

  def determine_role(user_context)
    user_context[:identity] || :unknown
  end

  def tone_for(role)
    case role
    when :father then :nurturing
    when :builder then :motivational
    when :strategist then :precise
    when :provider then :protective
    when :student then :curious
    else :neutral
    end
  end

  def style_for(role)
    case role
    when :father then { formality: :warm, energy: :low }
    when :builder then { formality: :direct, energy: :high }
    when :strategist then { formality: :sharp, energy: :medium }
    when :provider then { formality: :stable, energy: :grounded }
    when :student then { formality: :supportive, energy: :question-driven }
    else { formality: :neutral, energy: :neutral }
    end
  end

  def current_active_role
    # Placeholder — to be connected with current identity snapshot if tracked
    :builder
  end
end
