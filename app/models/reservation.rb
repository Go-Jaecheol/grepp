class Reservation < ApplicationRecord
  belongs_to :user

  enum :status, pending: "pending", confirmed: "confirmed", canceled: "canceled", default: "pending"

  validates :user_id, :start_time, :end_time, :headcount, presence: true
  validates :end_time, comparison: { greater_than: :start_time }
  validates :headcount, numericality: { only_integer: true, greater_than: 0 }

  validate :check_start_time_deadline
  validate :check_max_headcount

  private

  DEADLINE = 3.days.from_now
  MAX_HEADCOUNT = 50_000

  def check_start_time_deadline
    if start_time.present? && start_time < DEADLINE
      errors.add(:start_time, "예약은 최소 3일 전까지만 신청할 수 있습니다.")
    end
  end

  def check_max_headcount
    reservations = Reservation.where(
      "(start_time < ?) AND (end_time > ?) AND status = ?", end_time, start_time, "confirmed"
    )
    reserved_count = reservations.sum(:headcount)

    if headcount.present? && reserved_count + headcount > MAX_HEADCOUNT
      errors.add(:base, "같은 시간대에는 최대 50,000명까지만 예약할 수 있습니다.")
    end
  end
end
