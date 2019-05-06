require 'aws-sdk'

# AWS API
class AWS
  def self.preview_url
    @images = []
    s3 = Aws::S3::Resource.new(region: 'eu-west-2')
    s3.bucket('hogcam-photos').objects(prefix: 'preview').each do |img|
      @images << img
    end
    @images.last.presigned_url(:get)
  end
end
