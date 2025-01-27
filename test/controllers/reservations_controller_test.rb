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
      it "고객은 자신의 예약 목록을 조회할 수 있다." do
        # given
        user = users(:client_1)
        # when
        get reservations_url, params: { user_id: user.id }
        # then
        assert_response :ok
        actual = JSON.parse(response.body)

        user_ids = actual.map { |reservation| reservation["user_id"] }.uniq
        assert_equal [ user.id ], user_ids
      end

      it "어드민은 모든 예약 목록을 조회할 수 있다." do
        # given
        user = users(:admin_1)
        # when
        get reservations_url, params: { user_id: user.id }
        # then
        assert_response :ok
        actual = JSON.parse(response.body)
        assert_equal Reservation.count, actual.size
      end
    end
  end

  describe "예약 가능 시간 조회 API 테스트: GET /reservations/available" do
    describe "성공 테스트" do
      it "예약 가능한 시간 목록을 조회할 수 있다." do
        # given
        user = users(:client_1)
        # when
        get available_reservations_url, params: { date: (Time.current + 4.day).strftime("%Y-%m-%d") }
        # then
        assert_response :ok
        actual = JSON.parse(response.body)
        assert_equal 24, actual.size

        assert_equal "13:00", actual[13]["time"]
        assert_equal 40_000, actual[13]["confirmed_headcount"]
        assert_equal 10_000, actual[13]["available_headcount"]

        assert_equal "14:00", actual[14]["time"]
        assert_equal 50_000, actual[14]["confirmed_headcount"]
        assert_equal 0, actual[14]["available_headcount"]

        assert_equal "18:00", actual[18]["time"]
        assert_equal 0, actual[18]["confirmed_headcount"]
        assert_equal 50_000, actual[18]["available_headcount"]
      end
    end
  end

  describe "예약 수정 API 테스트: PATCH /reservations/:id" do
    describe "성공 테스트" do
      it "고객은 자신의 예약을 수정할 수 있다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        expected = {
          start_time: (Time.current + 4.day).change(hour: 1, min: 0, sec: 0),
          end_time: (Time.current + 4.day).change(hour: 2, min: 0, sec: 0),
          headcount: 2_000
        }
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: expected }
        # then
        assert_response :no_content
        reservation.reload
        assert_equal expected[:start_time].to_i, reservation.start_time.to_i
        assert_equal expected[:end_time].to_i, reservation.end_time.to_i
        assert_equal expected[:headcount], reservation.headcount
      end

      it "고객은 자신의 예약 시작 시간을 수정할 수 있다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        expected = { start_time: (Time.current + 4.day).change(hour: 17, min: 0, sec: 0) }
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: expected }
        # then
        assert_response :no_content
        reservation.reload
        assert_equal expected[:start_time].to_i, reservation.start_time.to_i
      end

      it "고객은 자신의 예약 종료 시간을 수정할 수 있다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        expected = { end_time: (Time.current + 4.day).change(hour: 20, min: 0, sec: 0) }
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: expected }
        # then
        assert_response :no_content
        reservation.reload
        assert_equal expected[:end_time].to_i, reservation.end_time.to_i
      end

      it "고객은 자신의 예약 인원 수를 수정할 수 있다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        expected = { headcount: 1 }
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: expected }
        # then
        assert_response :no_content
        reservation.reload
        assert_equal expected[:headcount], reservation.headcount
      end

      it "어드민은 고객의 예약을 수정할 수 있다." do
        # given
        user = users(:admin_1)
        reservation = reservations(:reservation_client2_18_19)
        expected = {
          start_time: (Time.current + 4.day).change(hour: 1, min: 0, sec: 0),
          end_time: (Time.current + 4.day).change(hour: 2, min: 0, sec: 0),
          headcount: 2_000
        }
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: expected }
        # then
        assert_response :no_content
        reservation.reload
        assert_equal expected[:start_time].to_i, reservation.start_time.to_i
        assert_equal expected[:end_time].to_i, reservation.end_time.to_i
        assert_equal expected[:headcount], reservation.headcount
      end
    end

    describe "예외 테스트" do
      it "수정한 start_time이 end_time보다 늦으면 400 에러를 반환한다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch reservation_url(reservation), params: {
          user_id: user.id,
          reservation: { start_time: reservation.end_time + 1.hour }
        }
        # then
        assert_response :bad_request
      end

      it "시작 시간까지 남은 시간이 3일 보다 적으면 400 에러를 반환한다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch reservation_url(reservation), params: {
          user_id: user.id,
          reservation: { start_time: Time.current + 2.day }
        }
        # then
        assert_response :bad_request
      end

      it "수정한 시간과 같은 시간대에 최대 인원 수(50_000명)를 초과하면 400 에러를 반환한다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch reservation_url(reservation), params: {
          user_id: user.id,
          reservation: {
            start_time: reservation.start_time.change(hour: 12),
            end_time: reservation.end_time.change(hour: 15)
          }
        }
        # then
        assert_response :bad_request
      end

      it "수정한 인원 수가 최대 인원 수(50_000명)를 초과하면 400 에러를 반환한다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: { headcount: 50_001 } }
        # then
        assert_response :bad_request
      end

      it "다른 고객의 예약을 수정하려고 하면 403 에러를 반환한다." do
        # given
        user = users(:client_1)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: { headcount: 1 } }
        # then
        assert_response :forbidden
      end

      it "확정되지 않은 예약을 수정하려고 하면 403 에러를 반환한다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_14_16)
        # when
        patch reservation_url(reservation), params: { user_id: user.id, reservation: { headcount: 1 } }
        # then
        assert_response :forbidden
      end
    end
  end

  describe "예약 확정 API 테스트: PATCH /reservations/:id/confirm" do
    describe "성공 테스트" do
      it "어드민은 예약을 확정할 수 있다." do
        # given
        user = users(:admin_1)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch confirm_reservation_url(reservation), params: { user_id: user.id }
        # then
        assert_response :no_content
        reservation.reload
        assert reservation.confirmed?
      end
    end

    describe "예외 테스트" do
      it "고객이 예약을 확정하려고 하면 403 에러를 반환한다." do
        # given
        user = users(:client_2)
        reservation = reservations(:reservation_client2_18_19)
        # when
        patch confirm_reservation_url(reservation), params: { user_id: user.id }
        # then
        assert_response :forbidden
      end

      it "이미 확정된 예약인 경우 400 에러를 반환한다." do
        # given
        user = users(:admin_1)
        reservation = reservations(:reservation_client2_14_16)
        # when
        patch confirm_reservation_url(reservation), params: { user_id: user.id }
        # then
        assert_response :bad_request
      end

      it "취소된 예약을 확정하려고 하는 경우 400 에러를 반환한다." do
        # given
        user = users(:admin_1)
        reservation = reservations(:reservation_client2_canceled)
        # when
        patch confirm_reservation_url(reservation), params: { user_id: user.id }
        # then
        assert_response :bad_request
      end
    end
  end
end
