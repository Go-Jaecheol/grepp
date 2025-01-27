class ApplicationController < ActionController::API
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  SECRET_KEY = Rails.application.credentials.secret_key_base

  private

  def handle_invalid_record(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    return head :unauthorized unless token

    begin
      decoded_token = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")
      user_id = decoded_token[0]["user_id"]
      @user = User.find_by(id: user_id)
    rescue JWT::DecodeError
      head :unauthorized
    end
  end
end
