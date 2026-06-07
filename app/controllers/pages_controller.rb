class PagesController < ApplicationController
  def home
    redirect_to "/dashboard" if session[:user_id].present?
  end
end
