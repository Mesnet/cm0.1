class UserInfosController < ApplicationController
  before_action :authenticate_user!
  def create
    respond_to do |format|
      @name = params[:user_info][:name].humanize.rstrip
      @surname = params[:user_info][:surname].humanize.rstrip
      @initial = @name[0] + @surname[0]
      if params[:user_info][:pseudo]
        @pseudo = params[:user_info][:pseudo].humanize.rstrip
      else 
        @pseudo =  @name + @surname
      end
      current_user.update(name: @name, surname: @surname, initial: @initial, pseudo: @pseudo)
      unless current_user.color.present?
        @colors = ["#1B998B","#DB162F","#FFC61E","#00B760","#E0ED44","#003D6B","#AD8799","#007FCC", "#E5E059", "#BDD358", "#999799", "#E5625E","#083D77", "#DA4167", "#F78764", "#00F0B5", "#F61067", "#FBB13C", "#218380", "#FFD400", "#2589BD", "#187795","#38686A", "#BDD358", "#3E6990", "#381D2A", "#AABD8C"]
        current_user.update(color: @colors.sample)
      end
      format.js { render "companies/js/step2" }
    end
  end

end
