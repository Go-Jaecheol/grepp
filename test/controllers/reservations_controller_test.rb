require "test_helper"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "예약 신청 API 테스트: POST /reservations" do
    # given
    expected = {
      user_id: users(:client_1).id,
      start_time: Time.now + 4.day,
      end_time: Time.now + 4.day + 1.hour,
      headcount: 1
    }
    # when
    post reservations_url, params: { reservation: expected }
    # then
    assert_response :created
    actual = Reservation.last
    assert_equal expected[:user_id], actual.user_id
    assert_equal expected[:start_time].to_i, actual.start_time.to_i
    assert_equal expected[:end_time].to_i, actual.end_time.to_i
    assert_equal expected[:headcount], actual.headcount
  end
end
