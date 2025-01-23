class Reservation < ApplicationRecord
  belongs_to :user

  enum :status, pending: "pending", confirmed: "confirmed", canceled: "canceled", default: "pending"

  validates :user_id, :start_time, :end_time, :headcount, presence: true
  validates :end_time, comparison: { greater_than: :start_time }
  validates :headcount, numericality: { only_integer: true, greater_than: 0 }
end
