class Comment < ActiveRecord::Base
  belongs_to :article

  scope :recent, -> { where('created_at > ?', 1.day.ago) }

  validates :body, presence: true
end
