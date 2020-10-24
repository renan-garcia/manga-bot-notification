# frozen_string_literal: true

require 'sinatra'
require_relative '../database'
require_relative '../models/manga'

get '/mangas' do
  Database.list(Manga).map { |f| "<li>#{f.title} : #{f.chapter} </li>"  }
end
