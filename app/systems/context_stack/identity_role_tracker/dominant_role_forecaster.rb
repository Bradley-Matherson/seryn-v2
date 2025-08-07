# dominant_role_forecaster.rb
# 🔮 Subcomponent: DominantRoleForecaster — predicts which identity role is likely to emerge next

require 'yaml'
require 'time'

module DominantRoleForecaster
  HISTORY_PATH = "data/context_stack/identity_history.yml"
  @suggested_next = nil

  def self.forecast(current_role)
    history = load_history
    recent_roles = history.last(12).map { |entry| entry[:role] }
    frequencies = recent_roles.tally

    # Remove current role from prediction
    frequencies.delete(current_role)

    # Sort by most frequent (but not currently active)
    prediction = frequencies.sort_by { |_role, count| -count }.first
    @suggested_next = prediction ? prediction[0] : default_fallback(current_role)
  end

  def self.default_fallback(current_role)
    fallback_sequence = {
      builder: :father,
      father: :strategist,
      strategist: :survivor,
      survivor: :creator,
      creator: :witness,
      witness: :provider,
      provider: :builder
    }
    fallback_sequence[current_role] || :strategist
  end

  def self.suggested_next
    @suggested_next
  end

  def self.load_history
    return [] unless File.exist?(HISTORY_PATH)
    YAML.load_file(HISTORY_PATH) || []
  end
end
