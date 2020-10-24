# frozen_string_literal: true

require 'sinatra'
require_relative '../telegram_service'

get '/telegrambot/run' do
  Thread.new { TelegramService.listen }
  'Bot run'
end
