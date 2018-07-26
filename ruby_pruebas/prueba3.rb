require 'sinatra'
require 'json_web_token'

SECRET = 'my_secret' 

get '/login' do
   #headers['HTTP_AUTHORIZATION'] = JWT.encode({user_id: 'user_id'}, SECRET)
   jwt = JsonWebToken.sign({foo: 'bar'}, key: 'gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C')

JsonWebToken.verify(jwt, key: 'gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C') 
end



get '/me' do
  JsonWebToken.verify(jwt, key: 'gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C') 
end