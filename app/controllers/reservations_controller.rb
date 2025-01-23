class ReservationsController < ApplicationController
  def create
    create_params = params.require(:reservation).permit(:user_id, :start_time, :end_time, :headcount)
    reservation = Reservation.new(create_params)

    reservation.save!
    head :created, location: url_for(reservation)
  end
end
