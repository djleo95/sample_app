class Micropost < ApplicationRecord
  belongs_to :user

  mount_uploader :picture, PictureUploader

  validate  :picture_size
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}

  scope :feeds, -> user_ids {where user_id: user_ids}
  scope :order_desc, -> {order created_at: :desc}

  private

  def picture_size
    if picture.size > 5.megabytes
      errors.add :picture, "should be less than 5MB"
    end
  end
end
