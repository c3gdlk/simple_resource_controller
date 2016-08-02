class Article < ActiveRecord::Base
  belongs_to :user
  has_many   :comments

  scope :recent, -> { order(created_at: :desc).limit(2) }

  validates :title, presence: true
end
