# frozen_string_literal: true

class Favorite
  attr_accessor :title, :active

  def initialize(**args)
    @title = args[:title]
    @active = args[:active]
  end

  def active?
    @active == 'true'
  end

  def active!
    @active = 'true'
  end

  def inactive!
    @active = 'false'
  end
end
