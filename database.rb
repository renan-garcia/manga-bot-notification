# frozen_string_literal: true

require_relative './models/manga'
require_relative './models/favorite'
require_relative './models/user'
require 'firebase'

module Database

  def self.insert(item)
    case item
    when Manga
      insert_manga(item)
    when User
      insert_user(item)
    when Favorite
      insert_favorite(item)
    else
      raise 'Tipo desconhecido'
    end
  end

  def self.update(item)
    case item
    when Manga
      update_manga(item)
    when User
      update_user(item)
    when Favorite
      update_favorite(item)
    else
      raise 'Tipo desconhecido'
    end
  end

  def self.list(item_class, filter = {})
    item = item_class.instance_of?(Class) ? item_class.new : item_class
    case item
    when Manga
      list_mangas(filter)
    when User
      list_users(filter)
    when Favorite
      list_favorites(filter)
    else
      raise 'Tipo desconhecido'
    end
  end

  private

  # Client
  def self.firebase
    private_key_json_string = Base64.urlsafe_decode64 ENV['FIREBASE_PRIVATE_KEY_BASE64']

    Firebase::Client.new(ENV['FIREBASE_URL'], private_key_json_string)
  end

  # Mangas

  def self.insert_manga(manga)
    firebase.push('mangas', { title: manga.title, chapter: manga.chapter, user_id: manga.user_id, created_at: Time.now })
  end

  def self.list_mangas(filter)
    mangas = []
    response = firebase.get('mangas', filter)
    return mangas if response.code != 200 || response.body.nil?

    response.body.each_key do |key|
      mangas << Manga.new(id: key, title: response.body[key]['title'], chapter: response.body[key]['chapter'], user_id: response.body[key]['user_id'])
    end
    mangas
  end

  def self.update_manga(manga)
    return if manga.id.nil?

    firebase.update("mangas/#{manga.id}", { title: manga.title, chapter: manga.chapter, user_id: manga.user_id, updated_at: Time.now })
  end

  # Favoritos

  def self.insert_favorite(favorite)
    firebase.push('favorites', { title: favorite.title, active: favorite.active, user_id: favorite.user_id, created_at: Time.now })
  end

  def self.list_favorites(filter)
    favorites = []
    response = firebase.get('favorites', filter)
    return favorites if response.code != 200 || response.body.nil?

    response.body.each_key do |key|
      favorites << Favorite.new(id: key, title: response.body[key]['title'], active: response.body[key]['active'], user_id: response.body[key]['user_id'])
    end
    favorites
  end

  def self.update_favorite(favorite)
    return if favorite.id.nil?

    firebase.update("favorites/#{favorite.id}", { title: favorite.title, active: favorite.active, user_id: favorite.user_id, updated_at: Time.now })
  end

  # User

  def self.insert_user(user)
    firebase.push('users', { first_name: user.first_name, last_name: user.last_name, cookie: user.cookie, chat_id: user.chat_id, active: user.active, created_at: Time.now })
  end

  def self.list_users(filter)
    users = []
    response = firebase.get('users', filter)
    return users if response.code != 200 || response.body.nil?

    response.body.each_key do |key|
      users << User.new(
        id: key,
        first_name: response.body[key]['first_name'],
        last_name: response.body[key]['last_name'],
        cookie: response.body[key]['cookie'],
        chat_id: response.body[key]['chat_id'],
        active: response.body[key]['active']
      )
    end
    users
  end

  def self.update_user(user)
    return if user.id.nil?

    firebase.update("users/#{user.id}", { first_name: user.first_name, last_name: user.last_name, cookie: user.cookie, chat_id: user.chat_id, active: user.active, updated_at: Time.now })
  end
end
