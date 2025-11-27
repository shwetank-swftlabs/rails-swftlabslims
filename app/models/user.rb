class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  def first_name
    email.split("@").first
  end
end