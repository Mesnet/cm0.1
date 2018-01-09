class UserInfosController < ApplicationController
  after_action :delete_uf

  def create
    @user_info = UserInfo.new(user_info_params)
    @name = @user_info.name.humanize.rstrip
    @surname = @user_info.surname.humanize.rstrip
    @initial = @name[0] + @surname[0]
    if @user_info.pseudo.present?
      @pseudo = @user_info.pseudo.humanize.rstrip
    else 
      @pseudo =  @name + @surname
    end
    current_user.update(name: @name, surname: @surname, initial: @initial, pseudo: @pseudo)
    unless current_user.color.present?
      @colors = ["#1B998B","#DB162F","#FFC61E","#00B760","#E0ED44","#003D6B","#AD8799","#007FCC", "#E5E059", "#BDD358", "#999799", "#E5625E","#083D77", "#DA4167", "#F78764", "#00F0B5", "#F61067", "#FBB13C", "#218380", "#FFD400", "#2589BD", "#187795","#38686A", "#BDD358", "#3E6990", "#381D2A", "#AABD8C"]
      current_user.update(color: @colors.sample)
    end
    respond_to do |format|
      if @user_info.save
        format.html { redirect_back }
        format.js { render "companies/js/step2" }
      else
        format.html { render "devise/registrations/user_info_register" }
        format.json { render json: @user_info.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_info_params
      params.require(:user_info).permit(:name, :surname, :pseudo, :role_name)
    end

    def delete_uf
      @user_info.delete
    end

end
