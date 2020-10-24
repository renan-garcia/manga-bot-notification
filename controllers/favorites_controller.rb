# frozen_string_literal: true

require 'sinatra'
require_relative '../database'
require_relative '../models/favorite'

get '/favorites' do
  Database.list(Favorite).map { |f| f.title }.join(',')
end
