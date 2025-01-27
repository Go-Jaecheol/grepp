class ReservationsController < ApplicationController
  before_action :find_user, only: [ :index, :update, :confirm, :cancel, :destroy ]
  before_action :find_reservation, only: [ :update, :confirm, :cancel, :destroy ]

  def create
    create_params = params.require(:reservation).permit(:start_time, :end_time, :headcount)
    reservation = Reservation.create!(create_params.merge(user_id: @login_user.id))
    head :created, location: url_for(reservation)
  end

  def index
    render json: Reservation.by_user_role(@user)
  end

  def available
    params.require(:date)
    date = Date.parse(params[:date].to_s)
    return render json: [] if date < Reservation::DEADLINE_DAYS.days.from_now.to_date

    render json: find_available_time_with_headcount(date)
  end

  def update
    update_params = params.require(:reservation).permit(:start_time, :end_time, :headcount)
    return head :forbidden unless check_updatable?(@user, @reservation)

    @reservation.update!(update_params)
    head :no_content
  end

  def confirm
    return head :forbidden unless @user.admin?

    @reservation.update!(status: :confirmed)
    head :no_content
  end

  def cancel
    return head :forbidden unless check_updatable?(@user, @reservation)

    @reservation.update!(status: :canceled)
    head :no_content
  end

  def destroy
    return head :forbidden unless check_updatable?(@user, @reservation)

    @reservation.destroy!
    head :no_content
  end

  private

  def find_user
    @user = User.find(@login_user.id)
  end

  def find_reservation
    @reservation = Reservation.find(params[:id])
  end

  def find_available_time_with_headcount(date)
    (0..23).map do |hour|
      confirmed_headcount = Reservation.sum_headcount_by_available_time(date, hour)
      available_headcount = [ Reservation::MAX_HEADCOUNT - confirmed_headcount, 0 ].max
      {
        time: format("%02d:00", hour),
        confirmed_headcount: confirmed_headcount,
        available_headcount: available_headcount
      }
    end
  end

  def check_updatable?(user, reservation)
    user.admin? || (user.client? && user.id == reservation.user_id && reservation.pending?)
  end
end
