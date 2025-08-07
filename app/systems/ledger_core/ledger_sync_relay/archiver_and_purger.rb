# 📘 ArchiverAndPurger — Archives and Cleans Ledger Data Over Time
# Subcomponent of LedgerCore::LedgerSyncRelay

require 'yaml'
require 'fileutils'
require 'date'

module LedgerCore
  module LedgerSyncRelay
    module ArchiverAndPurger
      ARCHIVE_DIR = "./data/ledger/archive"
      @last_archive_path = nil

      class << self
        def run(snapshot)
          archive_path = archive(snapshot)
          purge_old_data
          @last_archive_path = archive_path
        end

        def last_archive_path
          @last_archive_path
        end

        private

        def archive(snapshot)
          week_str = "W#{Date.today.cweek}"
          archive_path = "#{ARCHIVE_DIR}/#{Date.today.year}-#{week_str}.yml"
          FileUtils.mkdir_p(File.dirname(archive_path))

          archive_data = if File.exist?(archive_path)
                           YAML.load_file(archive_path) || []
                         else
                           []
                         end

          archive_data << {
            date: snapshot[:date] || Date.today.to_s,
            focus: snapshot[:focus],
            identity: snapshot[:identity_mode],
            energy: snapshot[:energy],
            momentum: snapshot[:momentum],
            streak: snapshot[:streak],
            task_count: snapshot[:task_count],
            reflections_due: snapshot[:reflections_due],
            milestones: snapshot[:milestones],
            self_care: snapshot[:self_care]
          }

          File.write(archive_path, archive_data.to_yaml)
          archive_path
        end

        def purge_old_data
          cutoff_date = Date.today - 30

          Dir.glob("#{ARCHIVE_DIR}/*.yml").each do |file_path|
            entries = YAML.load_file(file_path)

            next unless entries.is_a?(Array)

            cleaned = entries.reject do |entry|
              entry_date = parse_date(entry[:date])
              entry_date && entry_date < cutoff_date
            end

            if cleaned.empty?
              File.delete(file_path)
              puts "[🗑] Deleted empty archive: #{file_path}"
            else
              File.write(file_path, cleaned.to_yaml)
              puts "[✅] Purged outdated entries in: #{file_path}" if cleaned.size < entries.size
            end
          end

          purge_repeated_deferrals
        end

        def parse_date(date_str)
          Date.parse(date_str.to_s)
        rescue
          nil
        end

        def purge_repeated_deferrals
          memory_path = "./memory/task_memory/task_decay_alerts.yml"
          return unless File.exist?(memory_path)

          decay_log = YAML.load_file(memory_path)
          return unless decay_log.is_a?(Array)

          flagged = decay_log.select { |t| t[:skip_count].to_i >= 5 }

          flagged.each do |t|
            puts "[⚠️  Purged] Skipped task exceeded threshold: #{t[:title]}"
          end

          File.write(memory_path, decay_log.reject { |t| t[:skip_count].to_i >= 5 }.to_yaml)
        end
      end
    end
  end
end
