class BorrowRequestItem < ApplicationRecord
  belongs_to :borrow_request
  belongs_to :book

  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :book_id, uniqueness: {scope: :borrow_request_id}
  validate :quantity_not_exceed_available_books

  private

  def quantity_not_exceed_available_books
    return unless book && quantity

    return unless quantity > book.available_quantity

    errors.add(:quantity,
               "cannot exceed available quantity (#{book.available_quantity})")
  end
end
