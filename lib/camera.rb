# Camera interface
class Camera
  def self.status
    return 'OK' if supported && detected

    'Offline'
  end

  # private

  def self.supported
    diagnostics.first[-1].to_i == 1
  end

  def self.detected
    diagnostics.last[-1].to_i == 1
  end

  def self.diagnostics
    `vcgencmd get_camera`.split
  end

  private_class_method :diagnostics, :supported, :detected
end
