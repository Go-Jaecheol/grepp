require "test_helper"
require "minitest/spec"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  describe "예약 신청 API 테스트: POST /reservations" do
    # given
    def reservation_params
      {
        user_id: users(:client_1).id,
        start_time: (Time.current + 4.day).change(hour: 9, min: 0, sec: 0),
        end_time: (Time.current + 4.day).change(hour: 10, min: 0, sec: 0),
        headcount: 1_000
      }
    end

    describe "성공 테스트" do
      it "예약을 정상적으로 신청할 수 있다." do
        # when
        post reservations_url, params: { reservation: reservation_params }
        # then
        assert_response :created
        actual = Reservation.last
        assert_equal reservation_params[:user_id], actual.user_id
        assert_equal reservation_params[:start_time].to_i, actual.start_time.to_i
        assert_equal reservation_params[:end_time].to_i, actual.end_time.to_i
        assert_equal reservation_params[:headcount], actual.headcount
        assert actual.pending?
      end

      it "시험 시작까지 3일 남은 예약을 신청할 수 있다." do
        # given
        expected = reservation_params.merge(
          start_time: (Time.current + 3.day).change(hour: 9, min: 0, sec: 0),
          end_time: (Time.current + 3.day).change(hour: 10, min: 0, sec: 0)
        )
        # when
        post reservations_url, params: { reservation: expected }
        # then
        assert_response :created
        actual = Reservation.last
        assert_equal expected[:user_id], actual.user_id
        assert_equal expected[:start_time].to_i, actual.start_time.to_i
        assert_equal expected[:end_time].to_i, actual.end_time.to_i
        assert_equal expected[:headcount], actual.headcount
        assert actual.pending?
      end

      it "최대 인원 수를 초과하지 않으면 예약을 정상적으로 신청할 수 있다." do
        # given
        expected = reservation_params.merge(headcount: 50_000)
        # when
        post reservations_url, params: { reservation: expected }
        # then
        assert_response :created
        actual = Reservation.last
        assert_equal expected[:user_id], actual.user_id
        assert_equal expected[:start_time].to_i, actual.start_time.to_i
        assert_equal expected[:end_time].to_i, actual.end_time.to_i
        assert_equal expected[:headcount], actual.headcount
        assert actual.pending?
      end
    end

    describe "예외 테스트" do
      it "필수 파라미터가 없으면 400 에러를 반환한다." do
        # when
        invalid_params = reservation_params.except(:start_time)
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end

      it "start_time이 end_time보다 늦으면 400 에러를 반환한다." do
        # when
        invalid_params = reservation_params.merge(start_time: reservation_params[:end_time] + 1.hour)
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end

      it "시작 시간까지 남은 시간이 3일 보다 적으면 400 에러를 반환한다." do
        # when
        invalid_params = reservation_params.merge(
          start_time: (Time.current + 2.day).change(hour: 9, min: 0, sec: 0),
          end_time: (Time.current + 2.day).change(hour: 10, min: 0, sec: 0)
        )
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end

      it "같은 시간대에 최대 인원 수(50_000명)를 초과하는 예약을 생성하면 400 에러를 반환한다." do
        # when
        invalid_params = reservation_params.merge(
          start_time: (Time.current + 4.day).change(hour: 12, min: 0, sec: 0),
          end_time: (Time.current + 4.day).change(hour: 15, min: 0, sec: 0)
        )
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end

      it "같은 시간대에 기존 예약이 없어도 최대 인원 수(50_000명)를 초과하는 예약을 새로 생성하면 400 에러를 반환한다." do
        # when
        invalid_params = reservation_params.merge(headcount: 50_001)
        post reservations_url, params: { reservation: invalid_params }
        # then
        assert_response :bad_request
      end
    end
  end

  describe "예약 조회 API 테스트: GET /reservations" do
    describe "성공 테스트" do
      it "특정 유저의 예약 목록을 조회할 수 있다." do
        # given
        user = users(:client_1)
        # when
        get reservations_url, params: { user_id: user.id }
        # then
        assert_response :ok
      end
    end
  end
end
