require 'pg'
require 'rubygems'
require 'sinatra'
require 'json'

db_params = {
  host: 'localhost',
  dbname: 'tango',
  user: 'tango',
  password: 'tango'
}


  get '/' do
	erb :init
  end


get '/get_all' do
  psql = PG::Connection.new(db_params)
#  @usuarios = psql.exec_params('SELECT * FROM USERS')
 psql.exec( "SELECT * FROM USERS" ) do |result|
  puts "user | email    | role"
  result.each do |row|
    puts " %s | %s | %s " %
      row.values_at('name', 'email', 'role')
  end
  end

 puts "esto son todos los usuarios" 
 puts @usuarios	
end