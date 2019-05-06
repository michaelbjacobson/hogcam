require_relative './ssh_connection'

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
    SSHConnection.exec!('vcgencmd get_camera').split
  end

  private_class_method :diagnostics, :supported, :detected
end
