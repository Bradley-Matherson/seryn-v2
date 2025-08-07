# 📁 seryn/systems/output_control/output_archive/reflective_memory_cache.rb

require "fileutils"
require "yaml"
require "time"

module ReflectiveMemoryCache
  OUTPUT_DIR = "outputs/reflections"

  class << self
    def store_reflection(output)
      FileUtils.mkdir_p(OUTPUT_DIR)
      timestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
      filename = "#{timestamp}_#{output[:type]}_#{output[:tone] || 'neutral'}.yml"

      data = {
        prompt: output[:reflection_prompt],
        user_response: output[:response] || nil,
        mood: output[:mood],
        tone: output[:tone],
        triggers: output[:triggers] || [],
        context_mode: output[:mode],
        stored_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
      }

      File.write(File.join(OUTPUT_DIR, filename), data.to_yaml)
      puts "💬 Reflection cached: #{filename}"
    end
  end
end
