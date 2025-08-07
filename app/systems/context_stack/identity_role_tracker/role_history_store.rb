# role_history_store.rb
# 🗂️ Subcomponent: RoleHistoryStore — logs role, confidence, and timestamp to persistent history

require 'yaml'
require 'fileutils'
require 'time'

module RoleHistoryStore
  HISTORY_PATH = "data/context_stack/identity_history.yml"
  MAX_ENTRIES = 500

  def self.store(role, confidence)
    FileUtils.mkdir_p("data/context_stack")
    history = load
    history << {
      timestamp: Time.now.iso8601,
      role: role,
      confidence: confidence.round(2)
    }

    # Trim history if needed
    history.shift while history.size > MAX_ENTRIES
    File.write(HISTORY_PATH, history.to_yaml)
  end

  def self.load
    return [] unless File.exist?(HISTORY_PATH)
    YAML.load_file(HISTORY_PATH) || []
  end
end
