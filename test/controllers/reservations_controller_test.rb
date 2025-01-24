require "test_helper"
require "minitest/spec"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  describe "예약 신청 API 테스트: POST /reservations" do
    # given
    def expected
      {
        user_id: users(:client_1).id,
        start_time: Time.now + 4.day,
        end_time: Time.now + 4.day + 1.hour,
        headcount: 1
      }
    end

    it "성공 테스트" do
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

    describe "예외 테스트" do
      it "필수 파라미터가 없으면 400 에러를 반환한다." do
        # when
        invalid_params = expected.except(:start_time)
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end

      it "start_time이 end_time보다 늦으면 400 에러를 반환한다." do
        # when
        invalid_params = expected.merge(start_time: expected[:end_time] + 1.hour)
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end
    end
  end
end
