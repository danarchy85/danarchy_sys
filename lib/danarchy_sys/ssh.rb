require 'open3'
require 'shellwords'

class SSH
  def self.new(connector, opts = {})
    # connector: { ipv4: "str", ssh_user: "str", ssh_key: "str" }
    # options: { command: "str", timeout: int, quiet: true|false }
    opts[:timeout] ||= 30
    opts[:quiet]   ||= false
    pid, stdout, stderr = nil
    ssh  = "ssh -i '#{connector[:ssh_key]}' #{connector[:ssh_user]}@#{connector[:ipv4]} "
    ssh += "-o StrictHostKeyChecking=no "
    ssh += "-o ConnectTimeout=#{opts[:timeout]} " if opts[:timeout]
    
    if opts[:command]
      puts "Running '#{opts[:command]}' on '#{connector[:ipv4]}'" unless opts[:quiet]
      ssh += Shellwords.shellescape(opts[:command])

      Open3.popen3(ssh) do |i, o, e, t|
        pid = t.pid
        (out, err) = o.read, e.read
        stdout = !out.empty? ? out : nil
        stderr = !err.empty? ? err : nil
      end
    else
      return system(ssh)
    end

    if opts[:quiet] == false
      puts "------\nErrored at: #{caller_locations.first.label} Line: #{caller_locations.first.lineno}\nSTDERR: ", stderr, '------' if stderr
      puts "------\nSTDOUT: ", stdout, '------' if stdout
    end
    { pid: pid, stdout: stdout, stderr: stderr }
  end
end
