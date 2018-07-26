require 'rubygems'
require 'net-ldap'
require 'sinatra'
require 'json'
require 'jwt'






class SinatraApp < Sinatra::Base

  enable :sessions

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
	payload = {:user =>  session[:user], :roles => session[:roles]}
	token = JWT.encode payload, nil, 'none'
	puts token
	decoded_token = JWT.decode token, nil, false
	puts decoded_token
	tok = decoded_token	.to_s

	if tok.include? "developer"
		"Your are a developer, you can be here"
	else
		"NOT AUTHORIZED, you cannot be here"
	end

  end

  get '/customer' do

	payload = {:user =>  session[:user], :roles => session[:roles]}
	token = JWT.encode payload, nil, 'none'
	puts token
	decoded_token = JWT.decode token, nil, false
	puts decoded_token
	tok = decoded_token	.to_s

	if tok.include? "customer"
		"Your are a customer, you can be here"
	else
		halt 401, "Not authorized\n"
#		"NOT AUTHORIZED, you cannot be here"
	end

  end

  get '/logout' do
    session[:authenticated] = false
    redirect '/'
  end



  get '/' do
	erb :init
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

payload = {:user =>  session[:user], :roles => session[:roles]}
token = JWT.encode payload, nil, 'none'
puts token
decoded_token = JWT.decode token, nil, false
puts decoded_token
content_type :json
{ token: token}.to_json



#	erb :index
	
  end



end



SinatraApp.run! if __FILE__ == $0

__END__












