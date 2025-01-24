require "test_helper"

class ReservationTest < ActiveSupport::TestCase

  test "예약을 생성할 수 있다" do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day + 1.hour,
      headcount: 1
    )
    # then
    assert reservation.valid?, reservation.errors.full_messages
  end

  test "user_id가 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day + 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "user_id 없이 예약을 생성할 수 없습니다."
  end

  test "start_time이 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      end_time: Time.now + 4.day + 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "start_time 없이 예약을 생성할 수 없습니다."
  end

  test "end_time이 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.now + 4.day,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "end_time 없이 예약을 생성할 수 없습니다."
  end

  test "headcount가 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day + 1.hour
    )
    # then
    assert_not reservation.valid?, "headcount 없이 예약을 생성할 수 없습니다."
  end

  test "end_time이 start_time보다 빠른 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day - 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "end_time이 start_time보다 빠른 경우 예약을 생성할 수 없습니다."
  end

  test "headcount가 0명 이하인 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day + 1.hour,
      headcount: 0
    )
    # then
    assert_not reservation.valid?, "headcount가 0 이하인 경우 예약을 생성할 수 없습니다."
  end

  test "headcount가 정수가 아닌 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day + 1.hour,
      headcount: 1.5
    )
    # then
    assert_not reservation.valid?, "headcount가 정수가 아닌 경우 예약을 생성할 수 없습니다."
  end
end
