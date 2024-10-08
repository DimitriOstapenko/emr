class RaMessagesController < ApplicationController
  before_action :logged_in_user #, only: [:index, :edit, :update]

  def index
      @ra_messages = RaMessage.paginate(page: params[:page])
  end

  def show
    if RaMessage.exists?(params[:id])
       @ra_msg = RaMessage.find(params[:id])
       @ra_acc_msgs = RaAccount.where(ra_file: @ra_msg.ra_file)
    else
       redirect_to ra_messages_path
    end
  end

  def find
      str = params[:findstr].strip
      @ra_messages = myfind(str)
      if @ra_messages.any?
         @ra_messages = @ra_messages.paginate(page: params[:page])
         flash.now[:info] = "Found #{@ra_messages.count} #{'file'.pluralize(@ra_messages.count)} matching string #{str.inspect}"
         render 'index'
      else
         @ra_messages = RaMessage.new
         flash.now[:warning] = "RaMessage  #{str.inspect} was not found"
         render  inline: '', layout: true
      end
  end

private

  def ra_message_params
       params.require(:ra_message).permit(:msg_text, :ra_file, :date_paid, :group_no, :payee_name, :payee_addr, :amount, :pay_method, :bil_agent, :claims, :svcs, :sum_claimed, :sum_paid )
  end

  def myfind (str)
        if str.match(/^P\w+$/)               
          RaMessage.where("msg_text like ?", "%#{str}%")
	else 
	  RaMessage.where("date_paid like ?", "%#{str}%") 
        end
  end

end
