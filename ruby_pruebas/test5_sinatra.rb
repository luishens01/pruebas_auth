require 'rubygems'
require 'net-ldap'
require 'sinatra'
require 'json'



class SinatraApp < Sinatra::Base
  enable :sessions

  get '/' do
    erb "
    <a href='http://localhost:4567/login'>Login with LDAP</a><br>"
  end


  get '/login' do
	
	"hola illo"
	roles = Array.new

	##ldap configuration
	ldap = Net::LDAP.new :host => '127.0.0.1',
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

	ldap.search( :base => treebase, :filter => filter ) do |entry|
		entry.each do |at = attribute, va = values|
			if "#{at}" == "cn"
	    		puts "These are your roles: #{va}" 
			end
			if "#{at}" == "uid"
	    		puts "Your are logged as: #{va}"
			end		
		end
	end

  end



end



SinatraApp.run! if __FILE__ == $0

__END__












