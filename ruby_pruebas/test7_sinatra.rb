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
	@user="luis"

	#filter by name
	filter = Net::LDAP::Filter.eq( "uid", @user )
	treebase = "dc=tango,dc=eu"

  get '/prueba' do
	session[:roles] = {"Roles"=>"aaaaaaa"} 	
#	session[:roles]
	@rols = session[:roles]
	erb :index
  end



  get '/' do
    erb "
    <a href='http://localhost:4567/login'>Login with LDAP</a><br>"
  end


  get '/login' do
   
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
		if @permissions.include? "customer"
		@per = "developer and customer"
		end	
	end
	erb :index
	
  end



end



SinatraApp.run! if __FILE__ == $0

__END__












