class CompaniesController < ApplicationController
  before_action :set_company, except: [:info_step, :create, :new, :company_invit]
  before_action :authorization, except: [:info_step, :create, :new, :company_invit, :acc_invit, :den_invit]
  before_action :administrator, only: [:expel, :show_users, :update, :upd_role, :create_invit, :del_invit]

  # AJAX Action
  def quit
    respond_to do |format|
      if @company.cached_admins.include?(current_user) && @company.cached_admins.size == 1
        if @company.effectif == 1
          # Delete the company
          @company.destroy
          if current_user.companies.size == 0
            current_user.update(company: false)
            format.js {render inline: "location.reload();" }
          else 
            format.js { render "companies/js/quit"}
          end
        else
          # First Define an other admin
          format.js { render "companies/js/error_admin" }
        end
      else
        # Quit the company
        current_user.company_users.where(company: @company).delete_all
        @company.update(effectif: (@company.effectif -= 1))
        if current_user.companies.size == 0
          current_user.update(company: false)
          format.js {render inline: "location.reload();" }
        else 
          format.js { render "companies/js/quit"}
        end
      end
    end
  end

  def expel
    respond_to do |format|
      if @company.cached_admins.include?(current_user) && @company.cached_admins.size == 1
        # First Define an other admin
        format.js { render "companies/js/error_admin" }
      else
        @user = User.find(params[:userid])
        @company.company_users.where(user: @user).destroy
        if @user.id == current_user.id
          format.js {render inline: "location.reload();" }
        else 
          format.js { render "companies/js/expel"}
        end
      end
    end
  end

  def upd_role
    respond_to do |format|
      @user = User.find(params[:userid])
      if @company.cached_admins.include?(@user) && @company.cached_admins.size == 1
        format.js {render 'companies/js/error_admin'}
      else
        @company.company_users.where(user: @user).update(admin: params[:admin])
        if @user.id == current_user.id
          format.js {render inline: "location.reload();" }
        else 
          format.js { render "companies/js/upd_role"}
        end
      end
    end
  end

  def acc_invit
    respond_to do |format|
      if current_user.cached_company_invitations.include?(@company)
        current_user.company_users.where(user: current_user).update(invitation: false, participation: true)
        @company.update(effectif: (@company.effectif += 1))
        @idz = 1
        format.js { render "companies/js/rep_invit"}
      else 
        format.js {render inline: "location.reload();" }
      end
    end
  end

  def den_invit
    respond_to do |format|
      if current_user.cached_company_invitations.include?(@company)
        current_user.company_users.where(user: current_user).update(invitation: false)
        format.js { render "companies/js/rep_invit"}
      else 
        format.js {render inline: "location.reload();" }
      end
    end
  end

  def create_invit
  end

  def del_invit
  end

  #AJAX routing 
  def show_users
    @users = @company.cached_users
    respond_to do |format|
      format.js { render "companies/js/show_users"}
    end
  end

  def info_step
    respond_to do |format|
      format.html { redirect_back }
      format.js { render "companies/js/step"+params[:step] }
    end
  end

  #BASICS
  def create
    @company = Company.new(company_params)
    CompanyUser.create(company: @company, user: current_user, admin: true, participation: true)
    current_user.update(company: true)
    # @main_group = Group.create(name: @company.name, cat: 1, creator_id: current_user.id, effectif: 1, description: "Groupe principal de #{@company.name}", company: @company)
    # @my_group = Group.create(name: current_user.pseudo, cat: 2, creator_id: current_user.id, effectif: 1, description: "Groupe personnel de #{current_user.pseudo}", company: @company)
    # UsersGroup.create(group_id: @my_group.id, user_id: current_user.id, favorit: nil, participation: true)
    # UsersGroup.create(group_id: @main_group.id, user_id: current_user.id, favorit: true, participation: true)
    respond_to do |format|
      if @company.save
        if current_user.cached_admin_company.size == 1
          # Btn next step appear
          @idz = 1
        end
        format.html { redirect_back }
        format.js { render "companies/js/create" }
      else
        format.html { render redirect_back }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @company.update(company_params)
        format.js { render "companies/js/update" }
      else
        format.html { render redirect_back }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :size_type, :effectif)
  end

  def authorization
    unless @company.cached_users.include?(current_user)
      respond_to do |format|
        format.html notice: "vous ne faites pas partis de cette entreprise" 
        format.js {render inline: "location.reload();" }
      end
    end
  end

  def administrator
    unless @company.cached_admins.include?(current_user)
      respond_to do |format|
        format.html notice: "n'êtes pas administrateur" 
        format.js {render inline: "location.reload();" }
      end
    end
  end

end
