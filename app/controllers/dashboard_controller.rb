class DashboardController < ApplicationController
  include Secured

  def show
    @user = User.find(session[:user_id])
    @userinfo = session[:userinfo]
  end
end
