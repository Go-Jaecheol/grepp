class Reservation < ApplicationRecord
  belongs_to :user

  enum :status, pending: "pending", confirmed: "confirmed", canceled: "canceled", default: "pending"
end
