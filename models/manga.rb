# frozen_string_literal: true

class Manga
  attr_accessor :title, :chapter, :id

  def initialize(**args)
    @id = args[:id]
    @title = args[:title]
    @chapter = sanitize_chapter args[:chapter]
  end

  def sanitize_chapter(chapter)
    return nil if chapter.nil?

    chapter = chapter.gsub(/[^\d,\.]/, '')
    chapter = chapter[1..] if chapter[0] == '.'
    chapter
  end
end
