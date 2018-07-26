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
	  session[:data] = {"one"=>"a", "two"=>"a"} #params.inspect

	  session[:data]	
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
	@texto = "This are your roles:" 	
	@texto
#	@roles = session[:roles]
#	@roles
#	session[:roles]
  end



end



SinatraApp.run! if __FILE__ == $0

__END__












