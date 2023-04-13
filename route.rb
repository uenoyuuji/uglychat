require 'bundler'

Bundler.require :default

require 'securerandom'
require 'sinatra/base'
require 'yaml'

ActiveRecord::Base.configurations = YAML.load_file('environment/development/mysql.yml')
ActiveRecord::Base.establish_connection :writable
ActiveRecord::Base.enable_retry = true
ActiveRecord::Base.execution_tries = 3
ActiveRecord::Base.retry_mode = :rw
ActiveRecord::Base.execution_retry_wait = 1.5

['./lib', './model'].each do |d|
  Dir.glob(File.join(__dir__, d, '*.rb')).each do |f|
    require f
  end
end

class App < Sinatra::Base
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET']
  set :bind, '0.0.0.0'

  get '/' do
    session[:name] = SecureRandom.alphanumeric(10) unless session[:name]
    chats = Chat.order(id: :desc).limit(20)

    erb :index, locals: { name: session[:name], chats: chats }
  end

  post '/' do
    Chat.create(
      name: params[:name],
      message: params[:message],
      decorated_message: params[:decorated_message],
      created_at: Time.now.to_i
    )

    redirect '/'
  end
end
