class BillingsController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update]
        before_action :admin_user,   only: :destroy

  def index
      @billings = Billing.paginate(page: params[:page]) #, per_page: 40)
  end

  def edit
  end

  def update
  end


end
