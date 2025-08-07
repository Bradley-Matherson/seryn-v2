# seryn/guardian_protocol/violation_scanner/violation_history_log.rb

require 'json'
require 'fileutils'

module ViolationHistoryLog
  LOG_DIR = 'logs/guardian/violations'

  def self.record(violation)
    FileUtils.mkdir_p(LOG_DIR)
    date = Time.now.strftime('%Y-%m-%d')
    path = File.join(LOG_DIR, "#{date}.log")

    File.open(path, 'a') do |file|
      file.puts(JSON.pretty_generate(violation))
    end
  rescue => e
    puts "⚠️ Failed to log violation: #{e.message}"
  end

  def self.latest_entries(limit = 10)
    files = Dir["#{LOG_DIR}/*.log"].sort.reverse
    entries = []

    files.each do |file|
      File.readlines(file).reverse.each do |line|
        entries << JSON.parse(line) rescue next
        return entries if entries.size >= limit
      end
    end

    entries
  end
end
