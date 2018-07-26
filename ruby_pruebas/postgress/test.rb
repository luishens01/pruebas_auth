require 'rubygems'
require 'sinatra'
require 'json'
#require 'sinatra/activerecord'
require 'pg'


set :database_file, 'config/database.yml'

class Resource < ActiveRecord::Base
end

get '/' do
  json Resource.select('id', 'name').all
end






  get '/get_all' do
	@users = User.all
  end






  get '/customer' do
	'customer'	
  end

  get '/not_exists' do
	'This user does not exist in ldap'	
  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end



  get '/' do
	erb :init
  end


  get '/users_management' do
	erb :users
  end


 get '/get_role' do
	erb :get_rol
 end








SinatraApp.run! if __FILE__ == $0

__END__












