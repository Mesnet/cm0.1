class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :require_no_authentication
  before_filter :resource_name

  def user_info_register
  end

  def resource_name
    :user
  end

  def new  
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
  end

end

