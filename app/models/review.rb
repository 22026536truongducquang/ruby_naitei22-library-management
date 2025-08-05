class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :score, presence: true,
inclusion: {in: 1..5, message: "must be between 1 and 5"}
  validates :user_id,
            uniqueness: {scope: :book_id,
                         message: "can only review a book once"}

  scope :by_score, ->(score){where(score:)}
  scope :recent, ->{order(created_at: :desc)}
end
