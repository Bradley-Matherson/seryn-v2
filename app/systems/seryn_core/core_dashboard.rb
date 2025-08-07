# 📁 core/core_dashboard.rb

require_relative "system_matrix"
require_relative "seryn_context_stack"
require_relative "guardian_protocol"
require_relative "loop_triggers"

module CoreDashboard
  class << self
    def launch
      puts "[CoreDashboard] Interface launched."
      status_report
    end

    def status_report
      puts "\n🧠 SERYN DASHBOARD — #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
      puts "----------------------------------------"

      print_system_status
      print_strategy_progress
      print_context_snapshot
      print_autonomy_status
      print_active_loops

      puts "----------------------------------------\n"
    end

    private

    def print_system_status
      puts "\n🔧 SYSTEM STATUS"
      SystemMatrix.all_statuses.each do |key, info|
        status = info[:status].to_s.upcase
        trust = info[:trust_score].round(2)
        heartbeat = info[:last_heartbeat].strftime("%H:%M:%S")
        flag = info[:active] ? "✅" : "⛔"
        puts "#{flag} #{key.to_s.ljust(20)} | Status: #{status.ljust(8)} | Trust: #{trust} | Last ping: #{heartbeat}"
      end
    end

    def print_strategy_progress
      focus = SerynContextStack.get(:active_goal)
      task = SerynContextStack.get(:today_main_task)
      puts "\n📊 STRATEGY PROGRESS"
      puts "Focus Goal: #{focus || 'N/A'}"
      puts "Main Task: #{task || 'None Assigned'}"
    end

    def print_context_snapshot
      context = SerynContextStack.snapshot
      puts "\n🧠 EMOTIONAL / CONTEXT SNAPSHOT"
      puts "Energy:        #{context[:current_energy] || 'unknown'}"
      puts "Identity Mode: #{context[:identity_mode] || 'unset'}"
      puts "Focus Pillar:  #{context[:focus_pillar] || 'none'}"
      puts "Last Journal:  #{context[:last_journaling_marker] || 'N/A'}"
    end

    def print_autonomy_status
      guardian_data = GuardianProtocol.summary
      puts "\n⚙️ AUTONOMY + PERMISSION STATUS"
      puts "Self-Running Systems: #{guardian_data[:autonomous_systems].join(', ')}"
      puts "Restricted Systems:   #{guardian_data[:restricted_systems].join(', ')}"
      puts "Flags Today:          #{guardian_data[:flags_today]}"
    end

    def print_active_loops
      active_loops = LoopTriggers.active_loops
      puts "\n🔁 CURRENT FEEDBACK LOOPS"
      active_loops.each do |loop|
        puts "#{loop[:loop].to_s.ljust(24)} | Next Trigger: #{loop[:next_due].strftime("%Y-%m-%d %H:%M")}"
      end
    end
  end
end
