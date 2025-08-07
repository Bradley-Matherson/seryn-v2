# 📘 PDFOutputFormatter — Renders Daily Ledger Page to Printable PDF
# Subcomponent of LedgerCore::LedgerSyncRelay

require 'prawn'
require 'fileutils'
require 'date'

module LedgerCore
  module LedgerSyncRelay
    module PDFOutputFormatter
      class << self
        def render_pdf(snapshot)
          date_str = Date.today.strftime("%Y-%m-%d")
          path = "./outputs/ledger_pages/#{date_str}.pdf"
          FileUtils.mkdir_p(File.dirname(path))

          Prawn::Document.generate(path) do |pdf|
            pdf.font "Helvetica"
            pdf.text "🗓️ Ledger Daily Snapshot — #{date_str}", size: 18, style: :bold
            pdf.move_down 10

            pdf.text "🎯 Focus: #{snapshot[:focus]}"
            pdf.text "🧠 Identity Mode: #{snapshot[:identity_mode]}"
            pdf.text "⚡ Energy: #{snapshot[:energy]}"
            pdf.text "🔥 Momentum: #{snapshot[:momentum]}"
            pdf.text "📈 Streak: #{snapshot[:streak]}"
            pdf.text "💬 Reflection Due: #{snapshot[:reflections_due] ? 'Yes' : 'No'}"
            pdf.move_down 15

            if snapshot[:tasks]
              pdf.text "📋 Tasks:"
              snapshot[:tasks].each_with_index do |task, idx|
                pdf.text "#{idx + 1}. #{task[:title]}"
              end
            end

            if snapshot[:self_care]
              pdf.move_down 15
              pdf.text "💖 Self-Care:"
              snapshot[:self_care].each { |item| pdf.text "- #{item}" }
            end

            if snapshot[:milestones]
              pdf.move_down 15
              pdf.text "🏁 Milestones:"
              snapshot[:milestones].each do |m|
                bar = generate_progress_bar(m[:progress].to_f)
                pdf.text "- #{m[:id].to_s.gsub("_", " ").capitalize}: #{m[:progress]}% #{bar}"
              end
            end
          end

          path
        end

        def generate_progress_bar(percentage)
          filled = (percentage / 10).floor
          empty = 10 - filled
          "[" + ("■" * filled) + ("·" * empty) + "]"
        end
      end
    end
  end
end
