# http://stackoverflow.com/questions/2529990/activerecord-date-format
#
# Attributes:
# * id [integer, primary, not null] - primary key
# * audio_formats [text, default="--- []\n"] - TODO: document me
# * created_at [datetime] - creation time
# * description [text] - TODO: document me
# * duration [integer, default=30] - TODO: document me
# * ended_at [datetime] - TODO: document me
# * ends_at [datetime] - TODO: document me
# * featured_from [datetime] - TODO: document me
# * image_uid [string] - TODO: document me
# * play_count [integer, default=0] - TODO: document me
# * processed_at [datetime] - TODO: document me
# * record [boolean, default=true] - TODO: document me
# * recording [string] - TODO: document me
# * session [text] - TODO: document me
# * started_at [datetime] - TODO: document me
# * starts_at [datetime] - TODO: document me
# * state [string] - TODO: document me
# * teaser [string] - TODO: document me
# * title [string]
# * updated_at [datetime] - last update time
# * venue_id [integer] - belongs to :venue
class Talk < ActiveRecord::Base

  STATES = %w( prelive live postlive processing archived )
  
  # attr_accessible :title, :teaser, :starts_at, :duration,
  #                 :description, :record, :image

  belongs_to :venue, :inverse_of => :talks

  validates :venue, :title, :starts_at, :ends_at, presence: true

  before_validation :set_ends_at

  delegate :user, to: :venue

  image_accessor :image

  STATES.each do |state|
    scope state.to_sym, -> { where(state: state) }
  end
  scope :featured, -> { where.not(featured_from: nil) }

  def starts_in # seconds (for prelive)
    (starts_at - Time.now).to_i
  end

  def ends_in # seconds (for live)
    (ends_at - Time.now).to_i
  end

  private

  def set_ends_at
    return unless starts_at
    self.ends_at = starts_at + duration.minutes
  end

end
