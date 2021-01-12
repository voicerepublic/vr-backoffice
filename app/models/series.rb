# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime, not null] - creation time
# * description [text] - TODO: document me
# * duration [integer] - TODO: document me
# * featured_from [datetime] - TODO: document me
# * image_content_type [string] - TODO: document me
# * image_file_name [string] - TODO: document me
# * image_file_size [integer] - TODO: document me
# * image_uid [string] - TODO: document me
# * image_updated_at [datetime] - TODO: document me
# * options [text, default="--- {}\n"] - TODO: document me
# * start_time [datetime] - TODO: document me
# * teaser [text] - TODO: document me
# * title [string]
# * updated_at [datetime, not null] - last update time
# * user_id [integer] - belongs to :user
class Series < ApplicationRecord

  belongs_to :user
  has_many :talks
  before_save :set_description_as_html, if: :description_changed?

  validates :title, :teaser, :description, presence: true

  validates :title, length: { maximum: Settings.limit.string }
  validates :teaser, length: { maximum: Settings.limit.string }
  validates :description, length: { maximum: Settings.limit.text }

  # dragonfly_accessor :image

  has_one_attached :image

  def series_image_url
    if self.image.attachment
      self.image.attachment.service_url
    else
      '/assets/defaults/talk-image-a8f7b7353dcb14a287b371ae16fb7ddcf3c6898251e0e0774c08758c84fe73f5.jpg'
    end
  end
  
  def set_description_as_html
    self.description_as_html = MARKDOWN.render(description)
  end

  def disk_usage
    talks.map(&:disk_usage).inject(0) { |r, s| r + s }
  end

end
