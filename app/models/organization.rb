class Organization < ApplicationRecord

  has_many :devices
  has_many :memberships
  has_many :users, through: :memberships

  scope :ordered, -> { order(:name) }

end
