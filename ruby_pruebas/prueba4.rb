require 'sinatra'
require 'jwt'

SECRET = 'my_secret' 

get '/login' do
  params['pass'] == 'foo' ? JWT.encode({user_id: 123}, SECRET) : Forbidden



end
    
get '/me' do
  JWT.decode(params['token'], SECRET).to_s rescue 'Invalid token' 
end



