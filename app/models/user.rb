class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def first_name
    email.split("@").first
  end
end