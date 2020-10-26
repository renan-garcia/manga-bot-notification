# frozen_string_literal: true

require 'pry'
require 'json'
require 'awesome_print'

require_relative './neox_crawler'
require_relative './models/manga'
require_relative './models/user'
require_relative './telegram_service'
require_relative './database'

module Bot
  def self.manga_in_favorites?(manga, favorites_mangas_in_db, user)
    favorites_mangas_in_db.any? { |f| f.title == manga.title && f.active? && f.user_id == user.id }
  end

  def self.check_this_manga_chapter_in_db(manga, mangas_in_db, user)
    manga_in_db = mangas_in_db.find { |m| m.title == manga.title && m.user_id == user.id }

    return { status: :new } if manga_in_db.nil?

    return { status: :old } if manga_in_db.chapter.to_i >= manga.chapter.to_i

    manga_in_db.chapter = manga.chapter
    { status: :update, manga: manga_in_db }
  end

  def self.filter_mangas(mangas, user, ignore_favorites)
    filtered_mangas = []
    mangas_in_db = Database.list(Manga)
    favorites_mangas_in_db = Database.list(Favorite)

    mangas.each do |manga|
      next unless manga_in_favorites?(manga, favorites_mangas_in_db, user) || ignore_favorites

      check_result = check_this_manga_chapter_in_db(manga, mangas_in_db, user)
      next if check_result[:status] == :old

      check_result[:status] == :new ? Database.insert(manga) : Database.update(check_result[:manga])
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

  def self.search_latest_release_pages(user, number)
    text = String.new
    number.times do |index|
      mangas = NeoxCrawler.release_page(index)
      filtered_mangas = filter_mangas(mangas, user, false)
      text << print_result(filtered_mangas)
      sleep(5)
    end
    text
  end

  def self.search_favorites(user)
    mangas = NeoxCrawler.favorites(user)
    filtered_mangas = filter_mangas(mangas, user, true)
    print_result(filtered_mangas)
  end

  def self.search_my_mangas(user)
    mangas = Database.list(Manga)
    my_mangas = mangas.select { |m| m.user_id == user.id }
    print_result(my_mangas)
  end

  def self.register_user(cookie, chat_id, first_name, last_name)
    return if cookie.empty?

    Database.insert(User.new(cookie: cookie, chat_id: chat_id, first_name: first_name, last_name: last_name, active: 'true'))
  end

  def self.update_user(user, cookie)
    user.cookie = cookie
    user.active!
    Database.update(user)
  end

  def self.deactivate_user(user)
    user.inactive!
    Database.update(user)
  end
end
