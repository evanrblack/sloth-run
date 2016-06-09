require 'securerandom'
require 'sinatra/base'
require 'sinatra/flash'
require 'thin'
require 'websocket-eventmachine-server'

require './models/post'

class SlothRun < Sinatra::Base
  configure do
    enable :sessions
    register Sinatra::Flash
    
    set :posts, []
  end
  
  get '/' do
    @posts = settings.posts
    haml :index
  end

  post '/' do
    puts params
    #begin
      settings.posts << Post.new(params[:files], params[:body])
    #rescue Exception => e
    #  flash[:error] = e.message
    #end
    redirect '/'
  end

  get '/posts/:uuid' do
    @post = settings.posts.find{ |post| post.uuid == params[:uuid] }
    @post.visits += 1
    haml :post
  end
  
  post '/posts/:uuid' do
    @post = settings.posts.find{ |post| post.uuid == params[:uuid] }
    @post.votes += 1
    redirect to('/')
  end
end

EM.run do
  Thin::Server.start(SlothMoe)
end
