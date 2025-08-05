class Publisher < ApplicationRecord
  has_many :books, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP},
allow_blank: true
  validates :phone_number, length: {maximum: 20}
  validates :website,
            format: {with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w(http https))}\z/}, allow_blank: true
end
