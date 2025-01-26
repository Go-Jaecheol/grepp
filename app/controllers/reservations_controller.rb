class ReservationsController < ApplicationController
  def create
    create_params = params.require(:reservation).permit(:user_id, :start_time, :end_time, :headcount)
    reservation = Reservation.create!(create_params)
    head :created, location: url_for(reservation)
  end

  def index
    params.require(:user_id)
    reservations = Reservation.where(user_id: params[:user_id])
    render json: reservations
  end
end
