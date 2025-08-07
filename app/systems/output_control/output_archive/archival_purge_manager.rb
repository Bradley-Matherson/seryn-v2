# 📁 seryn/systems/output_control/output_archive/archival_purge_manager.rb

require "fileutils"
require "time"
require "yaml"

module ArchivalPurgeManager
  RETENTION_DAYS = 60
  PROTECTED_TAGS = ["pinned", "guardian_protected", "breakthrough"]

  OUTPUT_DIRS = {
    daily: "outputs/daily",
    voice: "outputs/voice",
    strategy: "outputs/strategy_snapshots",
    reflections: "outputs/reflections"
  }

  class << self
    def purge_according_to_rules
      OUTPUT_DIRS.each do |type, dir|
        purge_dir(dir, type)
      end
    end

    private

    def purge_dir(path, type)
      return unless Dir.exist?(path)

      Dir.each_child(path) do |file|
        full_path = File.join(path, file)
        next if File.directory?(full_path)

        if stale?(full_path) && !protected?(full_path, type)
          File.delete(full_path)
          puts "🗑️ Purged: #{full_path}"
        end
      end
    end

    def stale?(path)
      mtime = File.mtime(path)
      (Time.now - mtime) / (60 * 60 * 24) > RETENTION_DAYS
    rescue
      false
    end

    def protected?(path, type)
      return false unless type == :reflections

      begin
        content = YAML.load_file(path)
        tags = content["triggers"] || []
        (tags & PROTECTED_TAGS).any?
      rescue
        false
      end
    end
  end
end
