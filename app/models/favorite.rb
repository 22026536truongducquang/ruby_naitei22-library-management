class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favorable, polymorphic: true

  validates :user_id,
            uniqueness: {scope: [:favorable_id, :favorable_type],
                         message: "has already favorited this item"}

  scope :books, ->{where(favorable_type: "Book")}
  scope :authors, ->{where(favorable_type: "Author")}
end
