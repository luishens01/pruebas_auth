require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'omniauth-facebook'
require 'omniauth-twitter'
require 'omniauth-ldap'
#TODO require 'omniauth-att'

class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end
use OmniAuth::Builder do
  provider :ldap, :title => 'FH-Authentifizierung',
  :host => 'localhost',
  :port => 389,
  :method => :plain,
  :base => 'dc=tango,dc=eu',
  :uid => 'uid',
  :password => "admin",
  :try_sasl => false,
  :bind_dn => "cn=admin,dc=tango,dc=eu"
end

  
  get '/' do
    erb "
    <a href='http://localhost:4567/auth/github'>Login with Github</a><br>"
  end
  
  get '/auth/:provider/callback' do
    erb "<h1>#{params[:provider]} Login</h1>	
	<h1>You logged as: #{JSON.pretty_generate(request.env['omniauth.auth'].info.name)}</h1>
	<h2>We are checking if it is registered in ldap</h2>"
  end




  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end
  
  get '/auth/:provider/deauthorized' do
    erb "#{params[:provider]} has deauthorized this app."
  end
  
  get '/protected' do
    throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
    erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
         <a href='/logout'>Logout</a>"
  end
  
  get '/logout' do
    session[:authenticated] = false
    redirect '/'
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