# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'telegram/bot'
require 'dotenv/load'
require_relative './models/manga'
require_relative './models/user'
require_relative './database'
require_relative './bot'

TELEGRAM_TOKEN = ENV['TELEGRAM_TOKEN'] || 'SEU TOKEN'
CHAT_ID = ENV['CHAT_ID'] || 'CHAT ID'

module TelegramService
  def self.listen
    Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
      bot.listen do |message|
        command = prepare_command(message.text)
        case command[:function]
        when '/start'
          bot.api.send_message(chat_id: message.chat.id, text: 'Seja bem-vindo! Digite /help para lista de comandos. ¯ \ _ (ツ) _ / ¯')
        when '/register-update'
          if command[:args].nil?
            bot.api.send_message(chat_id: message.chat.id, text: 'Cookie é obrigatório.')
          else
            users = Database.list(User)
            user = users.find { |u| u.chat_id == message.chat.id }
            if user.nil?
              Bot.register_user(command[:args], message.chat.id, message.from.first_name, message.from.last_name)
              bot.api.send_message(chat_id: message.chat.id, text: 'Registro realizado')
            else
              Bot.update_user(user, command[:args])
              bot.api.send_message(chat_id: message.chat.id, text: 'Cookie atualizado e usuario ativado')
            end
          end
        when '/update-mangas'
          users = Database.list(User)
          user = users.find { |u| u.chat_id == message.chat.id && u.active? }
          if user.nil?
            bot.api.send_message(chat_id: message.chat.id, text: 'Usuário não cadastrado ou inativo')
          else
            result = Bot.search_favorites(user)
            bot.api.send_message(chat_id: message.chat.id, text: result.empty? ? 'Nenhum lançamento novo' : result)
          end
        when '/my-mangas'
          users = Database.list(User)
          user = users.find { |u| u.chat_id == message.chat.id && u.active? }
          if user.nil?
            bot.api.send_message(chat_id: message.chat.id, text: 'Usuário não cadastrado ou inativo')
          else
            result = Bot.search_my_mangas(user)
            bot.api.send_message(chat_id: message.chat.id, text: result)
          end
        when '/help'
          bot.api.send_message(chat_id: message.chat.id, text: help_message)
        when '/remove-register'
          users = Database.list(User)
          user = users.find { |u| u.chat_id == message.chat.id && u.active? }
          if user.nil?
            bot.api.send_message(chat_id: message.chat.id, text: 'Usuário não cadastrado ou inativo')
          else
            Bot.deactivate_user(user)
            bot.api.send_message(chat_id: message.chat.id, text: 'Usuário desativado')
          end
        end
      end
    end
  end

  def self.help_message
    <<-HEREDOC
      /register-update - Cria registro no bot parametro obrigatorio cookie da session do NeoxScanlator. Ex: /register-update __cfduid=d0c9c550851869c099e1b87f2... 
      /update-mangas - Força a atualização de checagem de novos mangas
      /my-mangas - Lista todos os seus mangas já trackeados pelo BOT
      /help - Lista de comandos
      /remove-register - Desativa seu registro no BOT para parar de trackear seus mangas favoritos

      Esse bot foi criado mais para uso pessoal e como achei que outras pessoas podem desejar isso eu disponibilizei para uso de terceiros. Não me responsabilizo por qualquer uso indevido. Para qualquer duvida ou sugestão acesse o repositório oficial do bot: https://github.com/renan-garcia/manga-bot-notification .
    HEREDOC
  end

  def self.send_message(chat_id, text)
    uri = URI.parse("https://api.telegram.org/bot#{TELEGRAM_TOKEN}/sendMessage")
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request.body = JSON.dump({ 'chat_id' => chat_id, 'text' => text, 'disable_notification' => false })

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
  end

  private

  def self.prepare_command(text)
    text = text.split(' ', 2)
    {
      function: text[0],
      args: text[1]
    }
  end
end
