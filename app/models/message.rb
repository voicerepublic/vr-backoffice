class Message < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :talk, optional: true

end
