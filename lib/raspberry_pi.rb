require 'json'
require 'net/ssh'
require_relative './camera'

# Raspberry Pi interface
class RaspberryPi
  def self.temp
    temp = `/usr/local/bin/temp`.strip
    "#{temp}°C"
  end

  def self.camera_status
    Camera.status
  end

  def self.mem
    `/usr/local/bin/mem`.strip
  end

  def self.running_timelapse?
    `/usr/local/bin/timelapse_running`.strip == 'true'
  end

  def self.running_stream?
    `/usr/local/bin/stream_running`.strip == 'true'
  end

  def self.uptime
    uptime = `echo $(awk '{print $1}' /proc/uptime)`.to_i
    duration = Time.at(uptime).utc
    hours = duration.strftime('%H').to_i
    minutes = duration.strftime('%M').to_i
    minutes_str = (minutes == 1 ? "#{minutes} minute" : "#{minutes} minutes")
    return minutes_str unless hours > 0

    hours_str = (hours > 1 ? "#{hours} hours" : "#{hours} hour")
    "#{hours_str}, #{minutes_str}"
  end

  def self.capture_still
    system('/usr/local/bin/preview')
  end

  def self.start_timelapse
    system('/usr/local/bin/start_timelapse')
  end

  def self.stop_timelapse
    system('/usr/local/bin/stop_timelapse')
  end

  def self.start_stream
    system('/usr/local/bin/start_stream')
  end

  def self.stop_stream
    system('/usr/local/bin/stop_stream')
  end

  def self.reboot
    system('sudo reboot')
  end

  def self.to_json
    status = {
      coreTemperature: temp,
      availableStorage: mem,
      cameraStatus: camera_status,
      uptime: uptime
    }
    status.to_json
  end

  def ssh_exec(str)
    Net::SSH.start("host", "user", :password => "password") do |ssh|
      result = ssh.exec!("ls -l")
      puts result
    end
  end

  def ssh_credentials
    {
        
    }
  end
end
