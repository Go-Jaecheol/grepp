require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "유저를 생성할 수 있다" do
    # given & when
    user = User.new(name: "테스트", role: "client")
    # then
    assert user.valid?, user.errors.full_messages
  end

  test "name이 없으면 예외가 발생한다." do
    # given & when
    user = User.new(role: "client")
    # then
    assert_not user.valid?, "name 없이 유저를 생성할 수 없습니다."
  end

  test "name이 중복되면 예외가 발생한다." do
    # given & when
    user = User.new(name: users(:client_1).name, role: "client")
    # then
    assert_not user.valid?, "name이 중복되면 유저를 생성할 수 없습니다."
  end
end
