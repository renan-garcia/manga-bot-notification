# frozen_string_literal: true

require 'sinatra'
require_relative '../telegram_service'
require_relative '../bot'

get '/bot/run' do
  Thread.new { 
    loop do
      text = Bot.search_favorites
      TelegramService.send_message("* Lançamentos do Dia #{Time.now.strftime('%m/%d/%Y %H:%M')}: * \n\n #{text}") unless text.empty?
      sleep(60 * 60)
    end
  }
  'Bot run'
end
