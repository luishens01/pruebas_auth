require 'rubygems'
require 'net-ldap'
require 'sinatra'
require 'json'

configure do
  enable :sessions

end


class SinatraApp < Sinatra::Base

	##ldap configuration
	ldap = Net::LDAP.new :host => 'localhost',
	     :port => 389,
	     :auth => {
	           :method => :simple,
	           :username => "cn=admin,dc=tango,dc=eu",
	           :password => "admin"
    		 }

	##user
#	@user="luis"



  post '/prueba' do
	params.to_s
  end

  get '/developer' do
	'Your are a developer'
  end

  get '/customer' do
	'Your are a customer'	
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

  post '/register' do
	puts "#{params[:name]}"
	puts "#{params[:password]}"
	puts "#{params[:email]}"
	puts "#{params[:rol]}"


	dn = "cn=#{params[:name]},cn=users,dc=tango,dc=eu"
	attr = {
	  :cn => "#{params[:rol]}",
	  :objectclass => ["top", "inetOrgPerson"],
	  :sn => "#{params[:name]}",
	  :mail => "#{params[:email]}",
          :uid => "#{params[:name]}",
          :userPassword => "#{params[:password]}"
	}
#	Net::LDAP.open (:host => 'localhost') do |ldap|

	ldap = Net::LDAP.new :host => 'localhost',
	     :port => 389,
	     :auth => {
	           :method => :simple,
	           :username => "cn=admin,dc=tango,dc=eu",
	           :password => "admin"
    		 }

	  ldap.add( :dn => dn, :attributes => attr )
end


 get '/get_rol' do
	erb :get_rol
 end

 post '/check_user' do

	#filter by name
	filter = Net::LDAP::Filter.eq( "mail", "#{params[:name]}" )
	treebase = "dc=tango,dc=eu"
   
	ldap.search( :base => treebase, :filter => filter ) do |entry|
		entry.each do |at = attribute, va = values|
			if "#{at}" == "cn"
	    		puts "These are your roles: #{va}"
			session[:roles] = {"Roles"=>"#{va}"} 			
			end
			if "#{at}" == "uid"
	    		puts "Your are logged as: #{va}"
			 session[:user] = {"User"=>"#{va}"}
			end		
		end

		@permissions = session[:roles].to_s
	

	if @permissions.include? "developer" 
		@per = "you are developer"
		puts @per
	end
	if @permissions.include? "customer"
		@per = "you are customer"
		puts @per
	end
	if @permissions.include? "admin"
		@per = "you are admin"
		puts @per
	end

	end	


 end


  post '/login' do

	#filter by name
	filter = Net::LDAP::Filter.eq( "uid", "#{params[:name]}" )
	treebase = "dc=tango,dc=eu"
   
	ldap.search( :base => treebase, :filter => filter ) do |entry|
		entry.each do |at = attribute, va = values|
			if "#{at}" == "cn"
	    		puts "These are your roles: #{va}"
			session[:roles] = {"Roles"=>"#{va}"} 			
			end
			if "#{at}" == "uid"
	    		puts "Your are logged as: #{va}"
			 session[:user] = {"User"=>"#{va}"}
			end		
		end
	end	
	
	@users = session[:user]
	@rols = session[:roles]

	@permissions = session[:roles].to_s
	

	if @permissions.include? "developer" 
		@per = "developer"
	end
	if (@permissions.include? "developer") && (@permissions.include? "customer")
		@per = "developer and customer"
	end
	if (@permissions.include? "developer") && (@permissions.include? "customer") && (@permissions.include? "admin")
		@per = "admin, developer and customer"
	end


	erb :index
	
  end



end



SinatraApp.run! if __FILE__ == $0

__END__












