# server.rb
require 'sinatra'
require "sinatra/namespace"
require'mongoid'

# DB Setup
Mongoid.load! "mongoid.config"

# Models
class Book
  include Mongoid::Document

  field :title, type: String
  field :author, type: String
  field :isbn, type: String

  validates :title, presence: true
  validates :author, presence: true
  validates :isbn, presence: true

  index({ title: 'text' })
  index({ isbn:1 }, { unique: true, name: "isbn_index" })
end


# Endpoints

get '/' do
  'hola cabesa'
end

get '/login' do
  'this is the login page'
end