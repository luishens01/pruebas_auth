require 'sinatra'
require 'jwt'
require 'json'



class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end

SECRET = 'my_secret' 


get '/login' do
  params['pass'] == 'foo'
  JWT.encode({user_id: '123'}, SECRET)
  params[:token] = JWT.encode({user_id: '123'}, SECRET)
  headers[:HTTP_AUTHORIZATION] = "bearer: " + JWT.encode({user_id: '123'}, SECRET)
  @token = params[:token]
  @token = headers[:HTTP_AUTHORIZATION]
   puts headers[:HTTP_AUTHORIZATION]
   env['HTTP_AUTHORIZATION'] = headers[:HTTP_AUTHORIZATION]
   request.env['HTTP_AUTHORIZATION'] = env['HTTP_AUTHORIZATION']
   puts env['HTTP_AUTHORIZATION'] 
    puts request.env['HTTP_AUTHORIZATION']


end


get '/me' do
 #token = "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMTIzIn0.Bo6vCiUScaAjMHhv-kdDMXgPDXFCBL48nIrgh4O2dHs"
 

 puts request.env['HTTP_TOKEN']

 token = env['HTTP_TOKEN'].split(' ')

# token = request.env['HTTP_TOKEN']
 puts token[1]
 puts JWT.decode(token[1], SECRET).to_s rescue 'Invalid token' 
  #content_type :text
  #return JSON.pretty_generate(request.env)
end



get '/cosas' do

puts "#{ request.env }"
  content_type :text
  return JSON.pretty_generate(request.env)
  #JWT.decode(@tok, SECRET).to_s rescue 'Invalid token' 
end

end

SinatraApp.run! if __FILE__ == $0

__END__



