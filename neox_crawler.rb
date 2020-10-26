# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'nokogiri'
require_relative './models/manga'

module NeoxCrawler
  def self.favorites(user)
    doc = Nokogiri::HTML(favorites_request(user.cookie))
    get_mangas_by_parse_favorites(doc, user.id)
  end

  def self.release_page(user, page)
    doc = Nokogiri::HTML(release_page_request(page))
    get_mangas_by_parse_releases(doc, user.id)
  end

  private

  def self.release_page_request(page)
    uri = URI.parse('https://neoxscans.com/wp-admin/admin-ajax.php')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    request['Authority'] = 'neoxscans.com'
    request['Pragma'] = 'no-cache'
    request['Cache-Control'] = 'no-cache'
    request['Accept'] = '*/*'
    request['Dnt'] = '1'
    request['X-Requested-With'] = 'XMLHttpRequest'
    request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36'
    request['Origin'] = 'https://neoxscans.com'
    request['Sec-Fetch-Site'] = 'same-origin'
    request['Sec-Fetch-Mode'] = 'cors'
    request['Sec-Fetch-Dest'] = 'empty'
    request['Referer'] = 'https://neoxscans.com/projects/?m_orderby=latest'
    request['Accept-Language'] = 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7'
    request['Cookie'] = '__cfduid=d0c9c550851869c099e1b87f22942904d1603428840'
    request.set_form_data(
      'action' => 'madara_load_more',
      'page' => page,
      'template' => 'madara-core/content/content-archive',
      'vars[manga_archives_item_layout]' => 'big_thumbnail',
      'vars[meta_key]' => '_latest_update',
      'vars[meta_query][relation]' => 'OR',
      'vars[order]' => 'desc',
      'vars[orderby]' => 'meta_value_num',
      'vars[paged]' => '1',
      'vars[post_status]' => 'publish',
      'vars[post_type]' => 'wp-manga',
      'vars[sidebar]' => 'right',
      'vars[template]' => 'archive'
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response.body
  end

  def self.favorites_request(cookie)
    uri = URI.parse('https://neoxscans.com/user-settings/?tab=bookmark')
    request = Net::HTTP::Get.new(uri)
    request['Authority'] = 'neoxscans.com'
    request['Pragma'] = 'no-cache'
    request['Cache-Control'] = 'no-cache'
    request['Upgrade-Insecure-Requests'] = '1'
    request['Dnt'] = '1'
    request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36'
    request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9'
    request['Sec-Fetch-Site'] = 'same-origin'
    request['Sec-Fetch-Mode'] = 'navigate'
    request['Sec-Fetch-User'] = '?1'
    request['Sec-Fetch-Dest'] = 'document'
    request['Referer'] = 'https://neoxscans.com/user-settings/?tab=history'
    request['Accept-Language'] = 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7'
    request['Cookie'] = cookie

    req_options = {
      use_ssl: uri.scheme == 'https',
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response.body
  end

  def self.get_mangas_by_parse_favorites(doc, user_id)
    doc.search('.item-infor').map { |manga| mount_manga_object(manga, user_id) }
  end

  def self.mount_manga_object(manga, user_id)
    Manga.new(title: manga.at('h3//a').children.text, chapter: manga.at('.chapter-item').at('a').text, user_id: user_id)
  end

  def self.get_mangas_by_parse_releases(doc, user_id)
    doc.search('.page-item-detail').map { |manga| mount_manga_object(manga, user_id) }
  end
end
