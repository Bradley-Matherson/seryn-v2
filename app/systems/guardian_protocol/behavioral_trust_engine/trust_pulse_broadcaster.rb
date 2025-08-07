# seryn/guardian_protocol/behavioral_trust_engine/trust_pulse_broadcaster.rb

module TrustPulseBroadcaster
  def self.send(system:, score:)
    # Notify key systems of trust update
    notify_permission_matrix(system, score)
    notify_training_system(system, score)
    notify_seryn_core(system, score)
    notify_response_engine(system, score)

    # Optional: Notify user if trust dipped dangerously
    if score < 0.7
      puts "⚠️ Seryn's trust in #{system} has dropped to #{score.round(2)}. Consider reviewing system permissions or behavior logs."
    end
  end

  def self.notify_permission_matrix(system, score)
    # Placeholder for real PermissionMatrix sync
    puts "🔐 PermissionMatrix updated for #{system}: trust #{score}"
  end

  def self.notify_training_system(system, score)
    # Placeholder hook for TrainingSystem integration
    puts "📚 TrainingSystem received trust update for #{system}: #{score}"
  end

  def self.notify_seryn_core(system, score)
    # Placeholder for SerynCore's awareness and regulation
    puts "🧠 SerynCore trust state for #{system}: #{score}"
  end

  def self.notify_response_engine(system, score)
    # Placeholder: Response tone modulation
    puts "🗣️ ResponseEngine updated tone bias for #{system}: trust score now #{score}"
  end
end
