# emotional_snapshot_store.rb
# 🗂️ EmotionalSnapshotStore — saves each emotion reading into live context and rolling history

require 'yaml'
require 'fileutils'

module EmotionalSnapshotStore
  LIVE_CONTEXT_PATH = "data/context_stack/current_state.yml"
  HISTORY_PATH = "data/context_stack/emotion_history.yml"
  HISTORY_LIMIT = 250

  def self.save_snapshot(emotion:, secondary:, risk:, momentum:)
    FileUtils.mkdir_p("data/context_stack")

    snapshot = {
      timestamp: Time.now,
      emotion: emotion,
      secondary: secondary,
      spiral_risk: risk,
      momentum: momentum,
    }

    update_live_context(snapshot)
    append_to_history(snapshot)
  end

  def self.update_live_context(snapshot)
    current_state = if File.exist?(LIVE_CONTEXT_PATH)
                      YAML.load_file(LIVE_CONTEXT_PATH) || {}
                    else
                      {}
                    end

    current_state[:emotion] = snapshot[:emotion]
    current_state[:secondary_emotion] = snapshot[:secondary]
    current_state[:spiral_risk] = snapshot[:spiral_risk]
    current_state[:momentum] = snapshot[:momentum]
    current_state[:emotion_updated_at] = Time.now

    File.write(LIVE_CONTEXT_PATH, current_state.to_yaml)
  end

  def self.append_to_history(snapshot)
    history = if File.exist?(HISTORY_PATH)
                YAML.load_file(HISTORY_PATH) || []
              else
                []
              end

    history << snapshot
    history.shift while history.size > HISTORY_LIMIT
    File.write(HISTORY_PATH, history.to_yaml)
  end
end
