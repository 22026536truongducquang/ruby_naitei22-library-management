class Author < ApplicationRecord
  has_one_attached :image

  has_many :books, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy

  validates :name, presence: true
  validates :nationality, length: {maximum: 100}
  validate :death_date_after_birth_date

  def total_favorites
    favorites.count
  end

  private

  def death_date_after_birth_date
    return unless birth_date && death_date

    return unless death_date < birth_date

    errors.add(:death_date, "must be after birth date")
  end
end
