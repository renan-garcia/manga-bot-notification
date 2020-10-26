# frozen_string_literal: true

require 'sinatra'
require_relative '../telegram_service'
require_relative '../bot'

get '/bot/run' do
  Thread.new {
    users = Database.list(User)
    active_users = users.select(&:active?)
    active_users.each do |user|
      text = Bot.search_favorites(user)
      TelegramService.send_message(user.chat_id, "* Lançamentos de #{Time.now.strftime('%m/%d/%Y %H:%M')}: * \n\n #{text}") unless text.empty?
    end
  }
  'Bot run'
end
