require 'rmagick'
require 'streamio-ffmpeg'

TYPE_TO_EXTENSION = Rack::Mime::MIME_TYPES.invert

SUPPORTED_TYPES = { 'image/jpeg' => :image,
                    'image/png' => :image,
                    'audio/mpeg' => :audio,
                    'video/webm' => :video
                  }

TAGS = [:anime, :manga, :technology, :video_games, :weapons]

class Post
  attr_accessor :uuid, :created_at, :file, :body, :thumbnail, :visits, :votes
  def initialize(file, body)
    raise "Empty post body" if body.strip.empty?
    @uuid = SecureRandom.uuid
    @created_at = Time.now
    if file
      @type = file[:type]
      if SUPPORTED_TYPES[@type]
        # Upload
        extension = TYPE_TO_EXTENSION[@type]
        filename = "#{uuid}#{extension}"
        path = "public/uploads/#{filename}"
        File.open(path, 'wb') do |f|
          f.write(file[:tempfile].read)
        end
        @file = "uploads/#{filename}"

        # Thumbnail
        case SUPPORTED_TYPES[@type]
        when :image
          path = "public/uploads/thumbnails/#{uuid}.jpg"
          thumbnail = Magick::ImageList.new("public/#{@file}").resize_to_fit(200, 200)
          thumbnail.write(path)
          @thumbnail = "uploads/thumbnails/#{uuid}.jpg"
        when :audio
          @thumbnail = 'images/audio.png'
        when :video
          path = "public/uploads/thumbnails/#{uuid}.jpg"
          FFMPEG::Movie.new("public/#{@file}").screenshot(path)
          Magick::ImageList.new(path).resize_to_fit!(200, 200)
          @thumbnail = "uploads/thumbnails/#{uuid}.jpg"
        end
      else
        raise "Unsupported file type #{file[:type]}"
      end
    end
    @body = body
    @visits = 0
    @votes = 0
  end
end
