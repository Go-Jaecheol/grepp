class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  private

  def handle_invalid_record(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def handle_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
