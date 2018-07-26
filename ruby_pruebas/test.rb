require 'rubygems'
require 'sinatra'
require 'net-ldap'
require 'digest/sha1'
require 'base64'
require 'haml'

LDAP_HOST = '127.0.0.1'

ADMIN_DN = 'cn=admin,dc=tango,dc=eu'
PEOPLE_DN = 'ou=groups,dc=tango,dc=eu'

PEOPLE_FILTER = Net::LDAP::Filter.eq('objectClass', 'inetOrgPerson')

PREFIX = '/ldap'

enable :sessions
enable :inline_templates

use Rack::MethodOverride

before do
  request.path_info = request.path_info.gsub(/^#{PREFIX}/, '')
end

helpers do
  def session_uid
    request.env['REMOTE_USER']
  end

  def admin?
    session_uid == 'admin'
  end

  def owner?(uid)
    admin? || session_uid == uid
  end

  def user_dn(uid)
    "uid=#{uid}," + PEOPLE_DN
  end
end

use Rack::Auth::Basic do |uid, password|
  if uid == 'admin'
    dn = ADMIN_DN
  else
    dn = "uid=#{uid}," + PEOPLE_DN
  end

  ldap = Net::LDAP.new(:host => LDAP_HOST)
  ldap.bind(:method => :simple, :username => dn, :password => password)
end

get '/' do
  ldap = Net::LDAP.new(:host => LDAP_HOST)
  @people = ldap.search(:base => PEOPLE_DN, :filter => PEOPLE_FILTER)

  haml :index
end

get '/people/new' do
  haml :new_person
end

post '/people/create' do
  halt 401 unless admin?

  dn = user_dn(params[:uid])

  full_name = params[:first_name] + ' ' + params[:last_name]

  attributes = {
    :objectclass => ['inetOrgPerson'],
    :uid => [params[:uid]],
    :sn => [params[:last_name]],
    :givenname => [params[:first_name]],
    :cn => [full_name],
    :displayname => [full_name],
    :mail => [params[:email]],
    :userpassword => [hash_password(params[:password])]
  }

  auth = {:method => :simple, :username => ADMIN_DN, :password => params[:admin_password]}
  Net::LDAP.open(:host => LDAP_HOST, :auth => auth) do |ldap|
    ldap.add(:dn => dn, :attributes => attributes)
  end

  redirect PREFIX + '/people/' + params[:uid]
end

get '/people/:uid' do
  ldap = Net::LDAP.new(:host => LDAP_HOST)
  persons = ldap.search(:base => user_dn(params[:uid]))
  raise Sinatra::NotFound unless persons
  @person = persons.first

  haml :person
end

post '/people/:uid/password' do
  halt 401 unless owner?(params[:uid])

  dn = user_dn(params[:uid])

  auth = {:method => :simple, :username => dn, :password => params[:current_password]}
  Net::LDAP.open(:host => LDAP_HOST, :auth => auth) do |ldap|
    npw_hash = hash_password(params[:new_password])
    change_password_op = [:replace, 'userPassword', [npw_hash]]
    ldap.modify(:dn => dn, :operations => [change_password_op])
  end

  redirect PREFIX + '/people/' + params[:uid]
end

delete '/people/:uid' do
  halt 401 unless admin?
  
  dn = user_dn(params[:uid])
  
  auth = {:method => :simple, :username => ADMIN_DN, :password => params[:admin_password]}
  Net::LDAP.open(:host => LDAP_HOST, :auth => auth) do |ldap|
    ldap.delete(:dn => dn)
  end

  redirect PREFIX + '/'
end

def hash_password(password)
  salt = 'salt'
  '{SSHA}' + Base64.encode64(Digest::SHA1.digest(password + salt) + salt).chomp!
end

__END__

@@ layout
%html
  %head
    %title LDAP Directory
    %script{ :src => 'https://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.min.js', :type => 'text/javascript'}
  %body
    = yield

@@ index
.people
  - @people.each do |person|
    .person
      %a{ :href => "#{PREFIX}/people/#{person[:uid].first}"}= person[:displayname].first
.new-person
  %a{ :href => "#{PREFIX}/people/new"} New Person

@@ new_person
%form{ :action => "#{PREFIX}/people/create", :method => 'POST'}
  %p
    %label{ :for => 'uid'} UID:
    %input{ :type =>'text', :name => 'uid'}
  %p
    %label{ :for => 'first_name'} First name:
    %input{ :type =>'text', :name => 'first_name'}
  %p
    %label{ :for => 'last_name'} Last name:
    %input{ :type =>'text', :name => 'last_name'}
  %p
    %label{ :for => 'email'} Email:
    %input{ :type =>'text', :name => 'email'}
  %p
    %label{ :for => 'password'} Password:
    %input{ :type =>'password', :name => 'password'}
  %p
    %label{ :for => 'password_confirmation'} Confirm Password:
    %input{ :type =>'password', :name => 'password_confirmation'}
  %p
    %label{ :for => 'admin_password'} Admin Password:
    %input{ :type =>'password', :name => 'admin_password'}
  %input{ :type => 'submit', :value => 'Create'}

@@ person
:javascript
  $(document).ready(function() {
    $('#change_password').submit(function() {
      var new_password = $.trim($('input[name="new_password"]').val())
      var new_password_confirmation = $.trim($('input[name="new_password_confirmation"]').val())
      
      if(new_password == '') {
        alert('Password cannot be empty or blank')
        return false   
      }

      if(new_password != new_password_confirmation) {
        alert('New password and confirmation do not match')
        return false
      }
    })

    $('#delete').submit(function() {
      return confirm('Are you sure you want to delete this users?')
    })
  })
%h3 #{@person[:displayname].first} - (#{@person[:uid].first})

- if owner?(@person[:uid].first)
  %form{ :id => 'change_password', :action => "#{PREFIX}/people/#{@person[:uid].first}/password", :method => 'POST' }
    %p
      %label{ :for => 'password'} Current Password:
      %input{ :type =>'password', :name => 'current_password'}
    %p
      %label{ :for => 'new_password'} New Password:
      %input{ :type =>'password', :name => 'new_password'}
    %p
      %label{ :for => 'new_password_confirmation'} Confirm New Password:
      %input{ :type =>'password', :name => 'new_password_confirmation'}
    %input{ :type => 'submit', :value => 'Set Password'}
- if admin?
  %form{ :id => 'delete', :action => "#{PREFIX}/people/#{@person[:uid].first}", :method => 'POST' }
    %input{ :type => 'hidden', :name => '_method', :value => 'DELETE' }
    %p
      %label{ :for => 'admin_password'} Admin Password:
      %input{ :type =>'password', :name => 'admin_password'}
    %button{ :type => 'submit' } Delete User