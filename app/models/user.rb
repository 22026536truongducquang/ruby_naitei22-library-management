class User < ApplicationRecord
  has_one_attached :image

  has_secure_password

  has_many :borrow_requests, dependent: :destroy
  has_many :approved_borrow_requests, class_name: "BorrowRequest",
foreign_key: "approved_by_admin_id", dependent: :nullify
  has_many :reviews, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_books, lambda {
                where(favorites: {favorable_type: "Book"})
              }, through: :favorites, source: :favorable, source_type: "Book"
  has_many :favorite_authors, lambda {
                where(favorites: {favorable_type: "Author"})
              }, through: :favorites, source: :favorable, source_type: "Author"

  enum role: {user: 0, admin: 1, super_admin: 2}
  enum gender: {male: 0, female: 1, other: 2}
  enum status: {inactive: 0, active: 1}

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :role, inclusion: {in: roles.keys}
  validates :gender, inclusion: {in: genders.keys}
  validates :status, inclusion: {in: statuses.keys}
  validates :date_of_birth, presence: true
  validates :phone_number, length: {maximum: 20}

  def favorited? favorable
    favorites.exists?(favorable:)
  end
end
