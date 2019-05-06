require 'net/ssh'
require_relative './camera'

# Raspberry Pi SSH interface
class RaspberryPi
  def self.temp
    temp = ssh_exec('temp', true).strip
    "#{temp}°C"
  end

  def self.camera_status
    Camera.status
  end

  def self.mem
    ssh_exec('mem', true).strip
  end

  def self.uptime
    uptime = ssh_exec("echo $(awk '{print $1}' /proc/uptime)", true).to_i
    duration = Time.at(uptime).utc
    hours = duration.strftime('%H').to_i
    minutes = duration.strftime('%M').to_i
    minutes_str = (minutes == 1 ? "#{minutes} minute" : "#{minutes} minutes")
    return minutes_str unless hours > 0

    hours_str = (hours > 1 ? "#{hours} hours" : "#{hours} hour")
    "#{hours_str}, #{minutes_str}"
  end

  def self.stream_active?
    ssh_exec('stream active', true).strip == 'true'
  end

  def self.start_stream
    ssh_exec('nohup stream start </dev/null &')
  end

  def self.stop_stream
    ssh_exec('nohup stream stop </dev/null &')
  end

  def self.timelapse_active?
    ssh_exec('timelapse active', true).strip == 'true'
  end

  def self.start_timelapse
    ssh_exec('nohup timelapse start </dev/null &')
  end

  def self.stop_timelapse
    ssh_exec('timelapse stop', true)
  end

  def self.update_preview
    ssh_exec('update_preview', true)
  end

  def self.reboot
    ssh_exec('sudo reboot')
  end

  def self.status
    {
      coreTemperature: temp,
      availableStorage: mem,
      cameraStatus: camera_status,
      uptime: uptime
    }
  end

  # private

  def self.credentials
    @credentials ||= {
      host: ENV['RASPI_HOST'],
      port: ENV['RASPI_PORT'],
      user: ENV['RASPI_USER'],
      password: ENV['RASPI_PASSWORD']
    }
  end

  def self.ssh_exec(command, wait = false)
    Net::SSH.start(
      credentials[:host],
      credentials[:user],
      port: credentials[:port], password: credentials[:password]
    ) { |ssh| wait ? ssh.exec!(command) : ssh.exec(command) }
  end

  private_class_method :credentials, :ssh_exec
end
