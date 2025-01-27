class AuthController < ApplicationController
  skip_before_action :authenticate_user!

  def login
    params.require(:name)
    user = User.find_by(name: params[:name])
    return head :unauthorized unless user

    token = JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, SECRET_KEY, "HS256")
    render json: { token: token }
  end
end
