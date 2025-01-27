require "test_helper"
require "minitest/spec"

class AuthControllerTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  describe "로그인 API 테스트: POST /login" do
    describe "성공 테스트" do
      it "로그인 성공 시 JWT 토큰을 반환한다." do
        # given
        user = users(:client_1)
        # when
        post login_url, params: { name: user.name }
        # then
        assert_response :ok
        assert_includes response.parsed_body, "token"
      end
    end

    describe "예외 테스트" do
      it "request body에 name이 없으면 400 에러를 반환한다." do
        # when
        post login_url
        # then
        assert_response :bad_request
      end

      it "등록되지 않은 유저로 로그인 시 401 에러를 반환한다." do
        # when
        post login_url, params: { name: "김도영" }
        # then
        assert_response :unauthorized
      end
    end
  end
end
