class Book < ApplicationRecord
  has_one_attached :image

  belongs_to :author
  belongs_to :publisher
  has_many :book_categories, dependent: :destroy
  has_many :categories, through: :book_categories
  has_many :borrow_request_items, dependent: :destroy
  has_many :borrow_requests, through: :borrow_request_items
  has_many :reviews, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy

  validates :title, presence: true
  validates :total_quantity, presence: true,
numericality: {greater_than_or_equal_to: 0}
  validates :available_quantity, presence: true,
numericality: {greater_than_or_equal_to: 0}
  validates :borrow_count, presence: true,
numericality: {greater_than_or_equal_to: 0}
  validate :available_quantity_not_greater_than_total

  def average_rating
    reviews.average(:score)&.round(1) || 0
  end

  def total_reviews
    reviews.count
  end

  def total_favorites
    favorites.count
  end

  private

  def available_quantity_not_greater_than_total
    return unless total_quantity && available_quantity

    return unless available_quantity > total_quantity

    errors.add(:available_quantity, "cannot be greater than total quantity")
  end
end
