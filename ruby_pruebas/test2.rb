require 'rubygems'
require 'net-ldap'
require 'sinatra' 

ldap = Net::LDAP.new :host => '127.0.0.1',
     :port => 389,
     :auth => {
           :method => :simple,
           :username => "cn=admin,dc=tango,dc=eu",
           :password => "admin"
     }

filter = Net::LDAP::Filter.eq( "cn", "admin*" )
treebase = "dc=tango,dc=eu"

ldap.search( :base => treebase, :filter => filter ) do |entry|
  puts "DN: #{entry.dn}"
  entry.each do |attribute, values|
    puts "   #{attribute}:"
    values.each do |value|
      puts "      --->#{value}"
    end
  end
end

get '/' do
	'p ldap.get_operation_result'
end


p ldap.get_operation_result