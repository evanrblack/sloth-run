require 'rmagick'
require 'streamio-ffmpeg'

TYPE_TO_EXTENSION = Rack::Mime::MIME_TYPES.invert

SUPPORTED_TYPES = { 'image/jpeg' => :image,
                    'image/png' => :image,
                    'image/gif' => :image,
                    'audio/mpeg' => :audio,
                    'video/webm' => :video
                  }

MAX_FILES = 5

TAGS = [:anime, :manga, :technology, :video_games, :weapons]

class Attachment
  attr_accessor :name, :type, :path, :thumbnail_path
  def initialize(file, uuid)
    
  end
end

class Post
  attr_accessor :uuid, :created_at, :files, :thumbnails, :body, :visits, :votes
  def initialize(files, body)
    raise "Empty post body" if files.nil? and body.strip.empty?
    @uuid = SecureRandom.uuid
    @created_at = Time.now
    if files
      # First check count
      raise "Too many files: #{files.length} / #{MAX_FILES}" if files.length > MAX_FILES
      
      # Then check types
      files.each do |file|
        # TODO: Use file utility here
        puts file.length
        type = file[:type]
        raise "Unsupported file type: #{file[:type]}" unless SUPPORTED_TYPES[file[:type]]
      end

      # Then move the temp file
      @files = []
      @thumbnails = []
      files.each_with_index do |file, index|
        extension = TYPE_TO_EXTENSION[file[:type]]
        filename = "#{uuid}-#{index}#{extension}"
        path = "public/uploads/#{filename}"
        File.open(path, 'wb') do |f|
          f.write(file[:tempfile].read)
        end
        @files << "uploads/#{filename}"

        # And create thumbnails
        case SUPPORTED_TYPES[file[:type]]
        when :image
          path = "public/uploads/thumbnails/#{uuid}-#{index}.jpg"
          thumbnail = Magick::ImageList.new("public/#{@files[index]}").resize_to_fit(200, 200)
          thumbnail.write(path)
          @thumbnails << "uploads/thumbnails/#{uuid}-#{index}.jpg"
        when :audio
          @thumbnails << 'images/audio.png'
        when :video
          temp_path = "/tmp/sloth-run-#{uuid}-#{index}.jpg"
          path = "public/uploads/thumbnails/#{uuid}-#{index}.jpg"
          FFMPEG::Movie.new("public/#{@files[index]}").screenshot(temp_path)
          thumbnail = Magick::ImageList.new(temp_path).resize_to_fit(200, 200)
          thumbnail.write(path)
          @thumbnails << "uploads/thumbnails/#{uuid}-#{index}.jpg"
        end
      end
    end
    @body = body
    @visits = 0
    @votes = 0
  end
end
