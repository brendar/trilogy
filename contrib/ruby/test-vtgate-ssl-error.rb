require 'open3'

def execute_command(cmd)
  puts cmd
  stdout, stderr, status = Open3.capture3(cmd)

  puts "stdout: #{stdout}"
  puts "stderr: #{stderr}"

  raise "Command '#{cmd}' failed with exit status #{status.exitstatus}" unless status.success?
end

execute_command("docker start trilogy_vtgate_1")

attempts = 0
vtgate_client = nil
begin
  puts "Connecting to vtgate"
  vtgate_client = Trilogy.new(host: "127.0.0.1", port: 23306, ssl: true, ssl_mode: Trilogy::SSL_REQUIRED_NOVERIFY)
rescue => e
  if e.message.include?("unable to connect")
    if attempts > 30
      raise "Cannot connect: #{e}"
    end
    sleep 1
    attempts += 1
    retry
  else
    raise
  end
end

puts "Querying vtgate"
vtgate_client.query("SELECT 1")

execute_command("docker stop trilogy_vtgate_1")

begin
  puts "Querying vtgate"
  vtgate_client.query("SELECT 1")
rescue => e
  if e.message.include?("TRILOGY_CLOSED_CONNECTION")
    puts "Good"
    exit 0
  else
    puts "Bad"
    exit 1
  end
end

