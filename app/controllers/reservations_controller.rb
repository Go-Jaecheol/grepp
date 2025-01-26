class ReservationsController < ApplicationController
  def create
    create_params = params.require(:reservation).permit(:user_id, :start_time, :end_time, :headcount)
    reservation = Reservation.create!(create_params)
    head :created, location: url_for(reservation)
  end

  def index
    params.require(:user_id)
    user = User.find(params[:user_id])

    reservations = Reservation.by_user_role(user)
    render json: reservations
  end
end
