# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'telegram/bot'
require 'dotenv/load'
require_relative './models/manga'
require_relative './database'
require_relative './bot'

TELEGRAM_TOKEN = ENV['TELEGRAM_TOKEN'] || 'SEU TOKEN'
CHAT_ID = ENV['CHAT_ID'] || 'CHAT ID'

module TelegramService
  def self.listen
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.listen do |message|
        case message.text
        when '/update-mangas'
          result = Bot.search_favorites
          bot.api.send_message(chat_id: message.chat.id, text: result.empty? ? 'Nenhum lançamento novo' : result )
        when '/mangas'
          bot.api.send_message(chat_id: message.chat.id, text: Database.list(Manga).map { |f| "#{f.title} : #{f.chapter} \n"}.join )
        end
      end
    end
  end

  def self.send_message(text)
    puts 'Enviando Mensagem para o Telegram'
    uri = URI.parse("https://api.telegram.org/bot#{TELEGRAM_TOKEN}/sendMessage")
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request.body = JSON.dump({ 'chat_id' => CHAT_ID, 'text' => text, 'disable_notification' => false })

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end
end
