# frozen_string_literal: true

class User
  attr_accessor :id, :first_name, :last_name, :cookie, :chat_id, :active

  def initialize(**args)
    @id = args[:id]
    @first_name = args[:first_name]
    @last_name = args[:last_name]
    @cookie = args[:cookie]
    @chat_id = args[:chat_id]
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
