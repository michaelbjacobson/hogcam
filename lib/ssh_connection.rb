require 'net/ssh'

# SSH Connection
class SSHConnection
  def self.exec!(command)
    session.exec!(command)
  end

  def self.exec(command)
    session.exec(command)
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

  def self.session
    @session ||= Net::SSH.start(
      credentials[:host],
      credentials[:user],
      port: credentials[:port], password: credentials[:password]
    )
  end

  private_class_method :session, :credentials
end
