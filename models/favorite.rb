# frozen_string_literal: true

class Favorite
  attr_accessor :title, :active, :id, :user_id

  def initialize(**args)
    @id = args[:id]
    @title = args[:title]
    @active = args[:active]
    @user_id = args[:user_id]
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
