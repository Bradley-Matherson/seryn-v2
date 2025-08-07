# mode_flag_controller.rb
# 🏁 ModeFlagController — tracks high-level operational modes (temporary, toggleable)

module ModeFlagController
  VALID_MODES = [
    :training_mode,
    :emergency_mode,
    :therapeutic_mode,
    :observer_only,
    :debug_routing
  ]

  @active_modes = []

  def self.activate(mode)
    return unless VALID_MODES.include?(mode)
    @active_modes << mode unless @active_modes.include?(mode)
  end

  def self.deactivate(mode)
    @active_modes.delete(mode)
  end

  def self.toggle(mode)
    @active_modes.include?(mode) ? deactivate(mode) : activate(mode)
  end

  def self.active_modes
    @active_modes.dup
  end

  def self.active?(mode)
    @active_modes.include?(mode)
  end

  def self.clear_all
    @active_modes = []
  end
end
