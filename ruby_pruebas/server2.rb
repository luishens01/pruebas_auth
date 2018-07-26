require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'omniauth-facebook'
require 'omniauth-twitter'
#TODO require 'omniauth-att'

class SinatraApp < Sinatra::Base
  configure do
    set :sessions, true
    set :inline_templates, true
  end
  use OmniAuth::Builder do
    #provider :github, '08acac5945ce57d4ec48','3b6f0d0f238ed7669a104e323462ce914dc80e69'    
    provider :github, 'ece9da5a3cff23b3475f','eb81c6098ba5d08e3c2dbd263bf11de5f3382d55'
    #provider :facebook, '290594154312564','a26bcf9d7e254db82566f31c9d72c94e'
    #provider :twitter, 'cO23zABqRXQpkmAXa8MRw', 'TwtroETQ6sEDWW8HEgt0CUWxTavwFcMgAwqHdb0k1M'
    #provider :att, 'client_id', 'client_secret', :callback_url => (ENV['BASE_DOMAIN']

  end
  
  get '/' do
    erb "
    <a href='http://localhost:4567/auth/github'>Login with Github</a><br>"
  end
  
  get '/auth/:provider/callback' do
    erb "<h1>#{params[:provider]}</h1>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
    redirect 'http://www.google.com'
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