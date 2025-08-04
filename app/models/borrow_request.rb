class BorrowRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by_admin, class_name: "User", optional: true
  has_many :borrow_request_items, dependent: :destroy
  has_many :books, through: :borrow_request_items

  enum status: {
    pending: 0,
    approved: 1,
    rejected: 2,
    borrowed: 3,
    returned: 4,
    overdue: 5,
    cancelled: 6
  }

  validates :request_date, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :status, inclusion: {in: statuses.keys}
  validate :end_date_after_start_date
  validate :admin_must_be_admin_role, if: :approved_by_admin_id?

  scope :by_status, ->(status){where(status:)}
  scope :overdue, lambda {where("end_date < ? AND status = ?", Date.current, statuses[:borrowed])
}

  private

  def end_date_after_start_date
    return unless start_date && end_date

    return unless end_date < start_date

    errors.add(:end_date, "must be after start date")

  end

  def admin_must_be_admin_role
    return unless approved_by_admin

    return if approved_by_admin.admin? || approved_by_admin.super_admin?

    errors.add(:approved_by_admin, "must be an admin")

  end
end
