require 'sinatra'
require 'jwt'

SECRET = 'my_secret' 

get '/me' do
  JWT.decode(token, SECRET)[0].to_s rescue 'Invalid token' 
end

get '/login' do
   headers['HTTP_AUTHORIZATION'] = JWT.encode({user_id: 'user_id'}, SECRET)
end