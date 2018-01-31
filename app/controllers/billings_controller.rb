class BillingsController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy

  def index
      date = params[:date] || Date.today
      @billings = Billing.where("date(visit_date) = ?", date)
      if @billings.any?
               @billings = @billings.paginate(page: params[:page])
               render 'index'
      else
         flash.now[:error] = 'No billings were found for date ' + date.inspect
         render 'shared/empty_page'
      end
  end

  def edit
  end

  def update
  end


end
