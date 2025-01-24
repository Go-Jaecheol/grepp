require "test_helper"

class ReservationTest < ActiveSupport::TestCase

  test "예약을 생성할 수 있다" do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 4.day,
      end_time: Time.current + 4.day + 1.hour,
      headcount: 1
    )
    # then
    assert reservation.valid?, reservation.errors.full_messages
  end

  test "user_id가 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      start_time: Time.current + 4.day,
      end_time: Time.current + 4.day + 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "user_id 없이 예약을 생성할 수 없습니다."
  end

  test "start_time이 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      end_time: Time.current + 4.day + 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "start_time 없이 예약을 생성할 수 없습니다."
  end

  test "end_time이 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 4.day,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "end_time 없이 예약을 생성할 수 없습니다."
  end

  test "headcount가 없으면 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 4.day,
      end_time: Time.current + 4.day + 1.hour
    )
    # then
    assert_not reservation.valid?, "headcount 없이 예약을 생성할 수 없습니다."
  end

  test "end_time이 start_time보다 빠른 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 4.day,
      end_time: Time.current + 4.day - 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "end_time이 start_time보다 빠른 경우 예약을 생성할 수 없습니다."
  end

  test "headcount가 0명 이하인 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 4.day,
      end_time: Time.current + 4.day + 1.hour,
      headcount: 0
    )
    # then
    assert_not reservation.valid?, "headcount가 0 이하인 경우 예약을 생성할 수 없습니다."
  end

  test "headcount가 정수가 아닌 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 4.day,
      end_time: Time.current + 4.day + 1.hour,
      headcount: 1.5
    )
    # then
    assert_not reservation.valid?, "headcount가 정수가 아닌 경우 예약을 생성할 수 없습니다."
  end

  test "시험 시작까지 남은 시간이 3일보다 적은 예약을 생성하는 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 2.day,
      end_time: Time.current + 2.day + 1.hour,
      headcount: 1
    )
    # then
    assert_not reservation.valid?, "start_time이 현재 시간으로부터 3일 이내인 경우 예약을 생성할 수 없습니다."
  end

  test "시험 시작까지 3일 남은 예약을 생성하는 경우 예약이 정상적으로 생성된다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: Time.current + 3.day,
      end_time: Time.current + 3.day + 1.hour,
      headcount: 1
    )
    # then
    assert reservation.valid?, reservation.errors.full_messages
  end

  test "같은 시간대에 최대 인원 수(50_000명)를 초과하는 예약을 생성하는 경우 예외가 발생한다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: (Time.current + 4.day).change(hour: 12, min: 0, sec: 0),
      end_time: (Time.current + 4.day).change(hour: 15, min: 0, sec: 0),
      headcount: 1_000
    )
    # then
    assert_not reservation.valid?, "같은 시간대에 최대 인원 수를 초과하는 예약을 생성할 수 없습니다."
  end

  test "예약을 생성해도 같은 시간대에 최대 인원 수(50_000명)를 초과하지 않는 경우 예약이 정상적으로 생성된다." do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: (Time.current + 4.day).change(hour: 13, min: 0, sec: 0),
      end_time: (Time.current + 4.day).change(hour: 14, min: 0, sec: 0),
      headcount: 1_000
    )
    # then
    assert reservation.valid?, reservation.errors.full_messages
  end

  test "경곗값인 경우 같은 시간대에 포함하지 않는다 (e.g. [13시~15시], [15시~16시]는 같은 시간대 X" do
    # given & when
    reservation = Reservation.new(
      user: users(:client_1),
      start_time: (Time.current + 4.day).change(hour: 15, min: 0, sec: 0),
      end_time: (Time.current + 4.day).change(hour: 16, min: 0, sec: 0),
      headcount: 1_000
    )
    # then
    assert reservation.valid?, reservation.errors.full_messages
  end
end
