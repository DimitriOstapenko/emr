class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction

  before_action :logged_in_user
  before_action :non_patient_user

  def index
    @schedules = Schedule.all
  end

  def show
  end

  def new
    @schedule = Schedule.new
  end

  def edit
  end

  def create
    @schedule = Schedule.new(schedule_params)

    if @schedule.save
      redirect_to schedules_url, notice: 'Schedule was created.' 
    else
      render :new 
    end
  end

  def update
    flash[:info] = params.inspect
    if @schedule.update(schedule_params)
      redirect_to schedules_url, notice: 'Schedule was updated.'
    else
      render :edit 
    end
  end

  def destroy
    @schedule.destroy
    redirect_to schedules_url, notice: 'Schedule was destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
      params.require(:schedule).permit(:doctor_id, :dow, :weeks, :start_time, :end_time)
    end
end
