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
    provider :ldap, :title => 'GateKeeper LDAP Login',
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
    <a href='http://localhost:4567/auth/ldap'>Login with LDAP</a><br>"
  end
  
  get '/auth/:provider/callback' do
    erb "<h1>#{params[:provider]}</h1>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
    redirect 'http://www.google.com'
  end

  post '/auth/ldap/callback' do
    "Hello World"
     redirect 'http://www.google.com'
  end

  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
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