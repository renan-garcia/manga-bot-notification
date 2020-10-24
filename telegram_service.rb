# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'telegram/bot'
require 'dotenv/load'

TELEGRAM_TOKEN = ENV['TELEGRAM_TOKEN'] || 'SEU TOKEN'
CHAT_ID = ENV['CHAT_ID'] || 'CHAT ID'

class TelegramService
  def self.listen
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.listen do |message|
        case message.text
        when '/ping'
          bot.api.send_message(chat_id: message.chat.id, text: "Funcionando, #{message.from.first_name} - #{message.chat.id}")
        when '/mangas'
          bot.api.send_message(chat_id: message.chat.id, text: search_last_pages(1))
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
