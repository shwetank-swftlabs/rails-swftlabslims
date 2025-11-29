class Comment < ApplicationRecord
  include DefaultDescOrder
  default_desc :created_at

  belongs_to :commentable, polymorphic: true
  has_rich_text :body

  validates :body, presence: true
  validates :created_by, presence: true
end