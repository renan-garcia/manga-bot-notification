# frozen_string_literal: true

require 'pry'
require 'json'
require 'awesome_print'

require_relative './neox_crawler'
require_relative './manga'
require_relative './telegram_service'
require_relative './database'

def manga_in_favorites?(manga, favorites_mangas_in_db)
  favorites_mangas_in_db.any? { |f| f.title == manga.title && f.active? }
end

def check_this_manga_chapter_in_db(manga, mangas_in_db)
  manga_in_db = mangas_in_db.find { |m| m.title == manga.title }
  return { status: :new } if manga_in_db.nil?

  return { status: :old } if manga_in_db.chapter.to_i >= manga.chapter.to_i

  { status: :update }
end

def filter_mangas(mangas, ignore_favorites)
  puts 'Filtrando mangas'
  filtered_mangas = []
  mangas_in_db = Database.list(Manga)
  favorites_mangas_in_db = Database.list(Favorite)

  mangas.each do |manga|
    next unless manga_in_favorites?(manga, favorites_mangas_in_db) || ignore_favorites

    check_result = check_this_manga_chapter_in_db(manga, mangas_in_db)
    puts 'Manga já existente já atualizado' if check_result[:status] == :old
    next if check_result[:status] == :old

    check_result[:status] == :new ? Database.insert(manga) : Database.update(manga)
    filtered_mangas << manga
  end

  filtered_mangas
end

def print_result(mangas)
  puts 'Printando resultado'
  text = String.new
  mangas.each do |manga|
    text << "<= #{manga.title} => \n"
    text << "Ultimo Capítulo: #{manga.chapter}\n"
    text << '============='
    text << "\n\n\n"
  end
  text
end

def search_latest_release_pages(number)
  puts 'Pegando as Paginas...'
  text = String.new
  number.times do |index|
    puts "Pegando a pagina #{index}"
    mangas = NeoxCrawler.release_page(index)
    filtered_mangas = filter_mangas(mangas, false)
    text << print_result(filtered_mangas)
    sleep(5)
  end
  puts ' === Busca Terminada ==='
  text
end

def search_favorites
  puts 'Pegando os Favoritos...'
  text = String.new
  mangas = NeoxCrawler.favorites
  filtered_mangas = filter_mangas(mangas, true)
  text << print_result(filtered_mangas)
  puts ' === Busca Terminada ==='
  text
end

text = search_favorites
puts "Msg enviada: #{text}".green
TelegramService.send_message("* Lançamentos do Dia #{Time.now.strftime('%m/%d/%Y %H:%M')}: * \n\n #{text}") unless text.empty?
