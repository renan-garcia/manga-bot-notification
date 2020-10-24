# frozen_string_literal: true

require 'pry'
require 'json'
require 'awesome_print'

require_relative './neox_crawler'
require_relative './models/manga'
require_relative './telegram_service'
require_relative './database'

module Bot
  def self.manga_in_favorites?(manga, favorites_mangas_in_db)
    favorites_mangas_in_db.any? { |f| f.title == manga.title && f.active? }
  end

  def self.check_this_manga_chapter_in_db(manga, mangas_in_db)
    manga_in_db = mangas_in_db.find { |m| m.title == manga.title }
    return { status: :new } if manga_in_db.nil?

    return { status: :old } if manga_in_db.chapter.to_i >= manga.chapter.to_i

    { status: :update }
  end

  def self.filter_mangas(mangas, ignore_favorites)
    filtered_mangas = []
    mangas_in_db = Database.list(Manga)
    favorites_mangas_in_db = Database.list(Favorite)

    mangas.each do |manga|
      next unless manga_in_favorites?(manga, favorites_mangas_in_db) || ignore_favorites

      check_result = check_this_manga_chapter_in_db(manga, mangas_in_db)
      next if check_result[:status] == :old

      check_result[:status] == :new ? Database.insert(manga) : Database.update(manga)
      filtered_mangas << manga
    end
    filtered_mangas
  end

  def self.print_result(mangas)
    text = String.new
    mangas.each do |manga|
      text << "<= #{manga.title} => \n"
      text << "Ultimo Capítulo: #{manga.chapter}\n"
      text << '============='
      text << "\n\n\n"
    end
    text
  end

  def self.search_latest_release_pages(number)
    text = String.new
    number.times do |index|
      mangas = NeoxCrawler.release_page(index)
      filtered_mangas = filter_mangas(mangas, false)
      text << print_result(filtered_mangas)
      sleep(5)
    end
    text
  end

  def self.search_favorites
    mangas = NeoxCrawler.favorites
    filtered_mangas = filter_mangas(mangas, true)
    print_result(filtered_mangas)
  end
end
