module Admin
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9._%+-]+@swftlabs\.com\z/, message: "must be a valid SWFTLabs email address ending with @swftlabs.com" }
    validates :is_admin, inclusion: { in: [true, false] }

    def first_name
      email.split("@").first
    end

    def is_same_user?(user)
      email == user.email
    end
  end
end