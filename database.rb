# frozen_string_literal: true

require 'sdbm'
require_relative './manga'
require_relative './favorite'

class Database

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

  # Mangas

  def self.insert_manga(manga)
    SDBM.open 'mangas' do |db|
      db[manga.title] = manga.chapter
    end
  end

  def self.list_mangas
    mangas = []
    SDBM.open 'mangas' do |db|
      db.each do |key, value|
        mangas << Manga.new(title: key, chapter: value)
      end
    end
    mangas
  end

  def self.update_manga(manga)
    SDBM.open 'mangas' do |db|
      db.update(manga.title => manga.chapter)
    end
  end

  # Favoritos

  def self.insert_favorite(favorite)
    SDBM.open 'favorites' do |db|
      db[favorite.title] = favorite.active
    end
  end

  def self.list_favorites
    favorites = []
    SDBM.open 'favorites' do |db|
      db.each do |key, value|
        favorites << Favorite.new(title: key, active: value)
      end
    end
    favorites
  end

  def self.update_favorite(favorite)
    SDBM.open 'favorites' do |db|
      db.update(favorite.title => favorite.active)
    end
  end
end
