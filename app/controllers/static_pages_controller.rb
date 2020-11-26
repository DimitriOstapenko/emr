class StaticPagesController < ApplicationController

  include PatientsHelper

  def home
    clear_pat_session
  end

  def help
  end

  def about
  end

  def contact
  end
  
  def news
  end

  def terms
  end

  def privacy
  end
end
