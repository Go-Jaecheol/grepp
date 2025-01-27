class ReservationsController < ApplicationController
  def create
    create_params = params.require(:reservation).permit(:user_id, :start_time, :end_time, :headcount)
    reservation = Reservation.create!(create_params)
    head :created, location: url_for(reservation)
  end

  def index
    params.require(:user_id)
    user = User.find(params[:user_id])
    render json: Reservation.by_user_role(user)
  end

  def available
    params.require(:date)
    date = Date.parse(params[:date].to_s)
    return render json: [] if date < Reservation::DEADLINE_DAYS.days.from_now.to_date

    render json: find_available_time_with_headcount(date)
  end

  private

  def find_available_time_with_headcount(date)
    (0..23).map do |hour|
      confirmed_headcount = Reservation.sum_headcount_by_available_time(date, hour)
      available_headcount = [Reservation::MAX_HEADCOUNT - confirmed_headcount, 0].max
      {
        time: format("%02d:00", hour),
        confirmed_headcount: confirmed_headcount,
        available_headcount: available_headcount
      }
    end
  end
end
