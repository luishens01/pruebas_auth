require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'omniauth-facebook'
require 'omniauth-twitter'
require 'omniauth-ldap'
require 'jwt'
#TODO require 'omniauth-att'





class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end
  use OmniAuth::Builder do
    provider :ldap, :title => 'GateKeeper LDAP Login',
    :host => 'localhost',
    :port => 389,
    :method => :plain,
    :base => 'ou=groups,dc=tango,dc=eu',
    :uid => 'uid',
    :password => "admin",
    :try_sasl => false,
    :bind_dn => "cn=admin,dc=tango,dc=eu"
  end



  
  get '/' do
    erb "
    <a href='http://localhost:4567/auth/ldap'>Login with LDAP</a><br>"
  end
  
  post '/auth/ldap/callback' do
	#{JSON.pretty_generate(request.env['omniauth.auth'])}
	puts "#{JSON.pretty_generate(request.env['omniauth.auth'])}"
	@name = "#{JSON.pretty_generate(request.env['omniauth.auth'].info.nickname)}"
	@uid = "#{JSON.pretty_generate(request.env['omniauth.auth'].uid)}"

	if @uid.include? "developer" 
		@per = "developer"
		payload = { data: 'developer', scopes: ['developer']}
		puts "developer"
	end
	if (@uid.include? "developer") && (@uid.include? "customer")
		@per = "developer and customer"
		payload = { data: 'developer and customer', scopes: ['developer', 'customer'] }
		puts "developer and customer"
	end
	if (@uid.include? "developer") && (@uid.include? "customer") && (@uid.include? "admin")
		@per = "admin, developer and customer"
		payload = { data: 'dmin, developer and customer' }
		puts "admin, developer and customer"
	end


#payload = { data: 'test' }
token = JWT.encode payload, nil, 'none'
content_type :json
{ token: token}.to_json

#puts token
#decoded_token = JWT.decode token, nil, false
#puts decoded_token













#	erb :index
  end



  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/developer' do
    erb "
    <a>Your are a developer</a><br>"
  end

  get '/customer' do
	     scopes = request.env.values_at :scopes

	    if scopes.include?('customer')
	      content_type :json
	      { customer: @accounts[scopes] }.to_json
	      { token: token}.to_json
	    else
	        halt 403
		content_type :json
		msg= "You dont have permission to access this endpoint"
		msg.to_json
    	end

  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end

end


SinatraApp.run! if __FILE__ == $0

__END__

@@ layout
<html>
  <head>
    <link href='http://twitter.github.com/bootstrap/1.4.0/bootstrap.min.css' rel='stylesheet' />
  </head>
  <body>
    <div class='container'>
      <div class='content'>
        <%= yield %>
      </div>
    </div>
  </body>
</html>