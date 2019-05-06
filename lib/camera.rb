require 'net/ssh'

# Camera interface
class Camera
  def self.status
    supported && detected ? 'OK' : 'Offline'
  end

  # private

  def self.supported
    diagnostics.first[-1].to_i == 1
  end

  def self.detected
    diagnostics.last[-1].to_i == 1
  end

  def self.diagnostics
    ssh_exec('vcgencmd get_camera', true).split
  end

  def self.credentials
    @credentials ||= {
      host: ENV['RASPI_HOST'],
      port: ENV['RASPI_PORT'],
      user: ENV['RASPI_USER'],
      password: ENV['RASPI_PASSWORD']
    }
  end

  def self.ssh_exec(command, wait)
    Net::SSH.start(
      credentials[:host],
      credentials[:user],
      port: credentials[:port], password: credentials[:password]
    ) { |ssh| wait ? ssh.exec!(command) : ssh.exec(command) }
  end

  private_class_method :credentials, :ssh_exec, :diagnostics, :supported, :detected
end
