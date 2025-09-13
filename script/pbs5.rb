require "net/http"
require_relative "../logs_parser/lib/logs_parser"

class LogFileMonitor
  def initialize(log_file_path, initial_position = 0)
    @log_file_path = log_file_path
    @file_position = initial_position
    @last_size = 0
    @last_mtime = Time.at(0)
    @file_handle = nil
  end

  def file_changed?
    return false unless File.exist?(@log_file_path)

    stat = File.stat(@log_file_path)
    size_changed = stat.size != @last_size
    mtime_changed = stat.mtime != @last_mtime

    @last_size = stat.size
    @last_mtime = stat.mtime

    size_changed || mtime_changed
  end

  def file_rotated?
    return false unless File.exist?(@log_file_path)

    stat = File.stat(@log_file_path)
    stat.size < @file_position
  end

  def read_new_lines
    return [] unless File.exist?(@log_file_path)

    if file_rotated?
      puts "Log file rotated, starting from beginning"
      @file_position = 0
      close_file
    end

    open_file
    @file_handle.seek(@file_position)

    new_lines = []
    while line = @file_handle.gets
      new_lines << line.chomp
    end

    @file_position = @file_handle.tell
    new_lines
  end

  def close
    close_file
  end

  private

  def open_file
    unless @file_handle && !@file_handle.closed?
      @file_handle = File.open(@log_file_path, "r")
    end
  end

  def close_file
    if @file_handle && !@file_handle.closed?
      @file_handle.close
      @file_handle = nil
    end
  end
end

def main
  if ARGV.length < 3
    puts "Usage: ruby pbs5.rb <game_name> <players_count> <pitboss_entries_password> [initial_position] [host]"
    puts "Example: ruby pbs5.rb my_game 4 secret_password 0 fierce-reaches-40697.herokuapp.com"
    exit 1
  end

  game_name = ARGV[0]
  players_count = ARGV[1].to_i
  password = ARGV[2]
  initial_position = ARGV[3].to_i || 0
  host = ARGV[4] || "fierce-reaches-40697.herokuapp.com"
  log_file_path = "net_message_debug.log"

  unless game_name && players_count > 0 && password
    puts "Error: game_name, players_count, and password are required"
    exit 1
  end

  parser = LogsParser::Service.new(game_name, players_count)
  http_adapter = LogsParser::HttpAdapter.new(host: host, password: password)
  monitor = LogFileMonitor.new(log_file_path, initial_position)

  iterations_counter = 0
  processed_lines = 0

  puts "Starting log monitor for #{game_name} (#{players_count} players)"
  puts "Initial position: #{initial_position}"
  puts "Host: #{host}"
  puts "Authentication: enabled"

  begin
    loop do
      iterations_counter += 1

      if monitor.file_changed?
        puts "Iteration #{iterations_counter} - File changed, processing new lines..."

        new_lines = monitor.read_new_lines

        if new_lines.empty?
          puts "No new lines to process"
        else
          puts "Processing #{new_lines.count} new lines..."

          new_lines.each do |line|
            begin
              if result = parser.call(line)
                response = http_adapter.send_data(result)
                puts "Sent: #{result.entry_type} - #{response.code}"
                processed_lines += 1
              end
            rescue LogsParser::HttpAdapter::NetworkError, LogsParser::HttpAdapter::ServerError => e
              puts "Error sending data: #{e.class} - #{e.message}"
              puts "Will retry on next iteration"
            end
          end
        end

        puts "Current position: #{monitor.instance_variable_get(:@file_position)}"
        puts "Total processed lines: #{processed_lines}"
      else
        puts "Iteration #{iterations_counter} - No changes detected"
      end

      sleep 5
    end
  rescue Interrupt
    puts "\nShutting down gracefully..."
  ensure
    monitor.close
    puts "Final position: #{monitor.instance_variable_get(:@file_position)}"
    puts "Total processed lines: #{processed_lines}"
  end
end

if __FILE__ == $0
  main
end
