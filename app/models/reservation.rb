class Reservation < ApplicationRecord
  belongs_to :user

  enum :status, pending: "pending", confirmed: "confirmed", canceled: "canceled", default: "pending"
  validates :user_id, :start_time, :end_time, :headcount, presence: true
end
