require 'aws-sdk-s3'

class AwsS3
  Movie = Struct.new(:date, :time, :url, keyword_init: true)

  def self.movies
    bucket.objects(prefix: 'movs').map do |m|
      next unless m.key.include? '.mp4'

      arr = m.key.split('/')
      Movie.new(
        date: arr[1],
        time: arr[2].chomp('.mp4'),
        url: m.presigned_url('GET')
      )
    end.compact
  end

  # private class methods

  def self.s3
    @s3 ||= Aws::S3::Resource.new
  end

  def self.bucket
    @bucket ||= s3.bucket('hogcam-photos')
  end

  private_class_method :s3, :bucket
end
