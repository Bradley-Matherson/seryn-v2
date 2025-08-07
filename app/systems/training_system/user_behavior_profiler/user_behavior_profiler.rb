# frozen_string_literal: true

# 🧠 UserBehaviorProfiler — Subsystem Controller
# Purpose:
# Coordinates Seryn’s understanding of your long-term behavior,
# including momentum rhythms, resistance triggers, identity saturation, and evolution patterns.

require_relative './momentum_cycle_mapper'
require_relative './resistance_detector'
require_relative './identity_load_balancer'
require_relative './emotional_anchor_library'
require_relative './behavioral_archetype_updater'

module TrainingSystem
  module UserBehaviorProfiler
    def self.run_full_profile_update
      profile = {
        identity_load: IdentityLoadBalancer.analyze_identity_distribution,
        resistance_patterns: ResistanceDetector.scan_for_avoidance,
        momentum_cycle: MomentumCycleMapper.map_cycle_pattern,
        emotional_anchors: EmotionalAnchorLibrary.fetch_active_anchors,
        current_archetype: BehavioralArchetypeUpdater.update_profile_archetype
      }

      store_profile(profile)
      forward_to_core_systems(profile)
      profile
    end

    def self.store_profile(data)
      File.write("data/user_behavior_profile.json", JSON.pretty_generate(data))
    end

    def self.forward_to_core_systems(profile)
      StrategyEngine.receive_behavior_profile(profile) if defined?(StrategyEngine)
      ResponseEngine.update_tone_profile(profile) if defined?(ResponseEngine)
      GuardianProtocol.evaluate_pushback_zones(profile) if defined?(GuardianProtocol)
      MissionCore.reweight_identity_focus(profile[:identity_load]) if defined?(MissionCore)
    end
  end
end
