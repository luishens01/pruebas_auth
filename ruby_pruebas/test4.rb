require 'rubygems'
require 'net-ldap'


ldap = Net::LDAP.new :host => '127.0.0.1',
     :port => 389,
     :auth => {
           :method => :simple,
           :username => "cn=admin,dc=tango,dc=eu",
           :password => "admin"
     }

##user
@user="luis"



#filter = Net::LDAP::Filter.eq( "cn", "developer" )
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



