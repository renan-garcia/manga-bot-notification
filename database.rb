# frozen_string_literal: true

require_relative './models/manga'
require_relative './models/favorite'
require 'firebase'

module Database

  def self.insert(item)
    case item
    when Manga
      insert_manga(item)
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
    when Favorite
      update_favorite(item)
    else
      raise 'Tipo desconhecido'
    end
  end

  def self.list(item_class)
    item = item_class.instance_of?(Class) ? item_class.new : item_class
    case item
    when Manga
      list_mangas
    when Favorite
      list_favorites
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
    firebase.push('mangas', { title: manga.title, chapter: manga.chapter })
  end

  def self.list_mangas
    mangas = []
    response = firebase.get('mangas')
    return mangas if response.code != 200 || response.body.nil?

    response.body.each_key do |key|
      mangas << Manga.new(id: key, title: response.body[key]['title'], chapter: response.body[key]['chapter'])
    end
    mangas
  end

  def self.update_manga(manga)
    return if manga.id.nil?

    firebase.update("mangas/#{manga.id}", { title: manga.title, chapter: manga.chapter })
  end

  # Favoritos

  def self.insert_favorite(favorite)
    firebase.push('favorites', { title: favorite.title, active: favorite.active })
  end

  def self.list_favorites
    favorites = []
    response = firebase.get('favorites')
    return favorites if response.code != 200 || response.body.nil?

    response.body.each_key do |key|
      favorites << Favorite.new(id: key, title: response.body[key]['title'], active: response.body[key]['active'])
    end
    favorites
  end

  def self.update_favorite(favorite)
    return if favorite.id.nil?

    firebase.update("favorites/#{favorite.id}", { title: favorite.title, active: favorite.active })
  end
end
