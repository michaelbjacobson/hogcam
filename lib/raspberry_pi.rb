require_relative './ssh_connection'
require_relative './camera'

# Raspberry Pi SSH interface
class RaspberryPi
  def self.temp
    temp = SSHConnection.exec!('temp').strip
    "#{temp}°C"
  end

  def self.camera_status
    Camera.status
  end

  def self.mem
    SSHConnection.exec!('mem').strip
  end

  def self.uptime
    uptime = SSHConnection.exec!("echo $(awk '{print $1}' /proc/uptime)").to_i
    duration = Time.at(uptime).utc
    hours = duration.strftime('%H').to_i
    minutes = duration.strftime('%M').to_i
    minutes_str = (minutes == 1 ? "#{minutes} minute" : "#{minutes} minutes")
    return minutes_str unless hours > 0

    hours_str = (hours > 1 ? "#{hours} hours" : "#{hours} hour")
    "#{hours_str}, #{minutes_str}"
  end

  def self.stream_active?
    SSHConnection.exec!('stream active').strip == 'true'
  end

  def self.start_stream
    SSHConnection.exec('sudo nohup stream start </dev/null &')
  end

  def self.stop_stream
    SSHConnection.exec('sudo nohup stream stop </dev/null &')
  end

  def self.timelapse_active?
    SSHConnection.exec!('timelapse active').strip == 'true'
  end

  def self.start_timelapse
    SSHConnection.exec('sudo nohup timelapse start </dev/null &')
  end

  def self.stop_timelapse
    SSHConnection.exec('sudo nohup timelapse stop </dev/null &')
  end

  def self.update_preview
    SSHConnection.exec('sudo nohup /usr/local/bin/update_preview </dev/null &')
  end

  def self.reboot
    SSHConnection.exec('sudo reboot')
  end

  def self.status
    {
      coreTemperature: temp,
      availableStorage: mem,
      cameraStatus: camera_status,
      uptime: uptime
    }
  end
end
