class User < ActiveRecord::Base
  has_many :articles

  scope :moderators, -> { where(moderator: true) }

  validates :name, presence: true
end
