class Reservation < ApplicationRecord
  belongs_to :user

  DEADLINE_DAYS = 3
  MAX_HEADCOUNT = 50_000

  enum :status, { pending: "pending", confirmed: "confirmed", canceled: "canceled" }, default: :pending

  scope :by_user_role, ->(user) {
    return all if user.admin?
    where(user_id: user.id)
  }
  scope :sum_headcount_by_available_time, ->(date, hour) {
    where(
      "status = 'confirmed' AND start_time <= ? AND end_time > ?",
      date.to_datetime.change(hour: hour),
      date.to_datetime.change(hour: hour)
    ).sum(:headcount)
  }

  validates :user_id, :start_time, :end_time, :headcount, presence: true
  validates :end_time, comparison: { greater_than: :start_time }
  validates :headcount, numericality: { only_integer: true, greater_than: 0 }
  validate :check_start_time_deadline
  validate :check_max_headcount

  private

  def check_start_time_deadline
    if start_time.present? && start_time.to_date < DEADLINE_DAYS.days.from_now.to_date
      errors.add(:start_time, "예약은 최소 #{DEADLINE_DAYS}일 전까지만 신청할 수 있습니다.")
    end
  end

  def check_max_headcount
    reservations = Reservation.where(
      "(start_time < ?) AND (end_time > ?) AND status = ?", end_time, start_time, "confirmed"
    )
    reserved_count = reservations.sum(:headcount)

    if headcount.present? && reserved_count + headcount > MAX_HEADCOUNT
      errors.add(:base, "같은 시간대에는 최대 #{MAX_HEADCOUNT}명까지만 예약할 수 있습니다.")
    end
  end
end
