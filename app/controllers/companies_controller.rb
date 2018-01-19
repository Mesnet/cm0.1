class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :have_company, only: [:info_step, :company_invit]
  before_action :set_company, except: [:info_step, :create, :new, :company_invit]
  before_action :authorization, except: [:info_step, :create, :new, :company_invit, :acc_invit, :den_invit]
  before_action :administrator, only: [:expel, :show_users, :update, :upd_role, :del_invit]

  # AJAX Action
  def quit
    respond_to do |format|
      if @company.cached_admins.include?(current_user) && @company.cached_admins.size == 1
        if @company.effectif == 1
          # Delete the company
          @company.destroy
          if current_user.companies.size == 0
            # User have to remake his registration
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
        @groups = @company.groups
        current_user.group_users.where(group_id: @groups).delete_all
        @company.update(effectif: (@company.effectif -= 1))
        @group = @company.groups.first
        @group.update(effectif: (@group.effectif -= 1))
        if current_user.companies.size == 0
          # User have to remake his registration
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
        GroupUser.where(user: @user, group: @company.groups).delete_all
        @company.update(effectif: (@company.effectif -= 1))
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
        @cu = @company.company_users.where(user: @user)
        if params[:admin]
          @cu.update(admin: true)
        else 
          @cu.update(admin: false)
        end
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
        current_user.update(pend_invit: (current_user.pend_invit -= 1))
        @group = @company.groups.first
        @group_user = @group.group_users.where(user: current_user).first_or_create
        @group_user.update(participation: true, favorit: true)
        @group.update(effectif: (@group.effectif += 1))
        unless current_user.company?
          current_user.update(company: true)
          @idy = 1
        end
        if params[:home]
          @idz = 2
        else
          @idz = 1
        end
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

  def del_invit
    @cu = @company.company_users.find(params[:invitid])
    if @cu.user_id.present? && @cu.invitation?
      user = User.find(@cu.user_id)
      user.update(pend_invit: (current_user.pend_invit -= 1))
    end
    @cu.destroy
    respond_to do |format|
      format.js { render "companies/js/del_invit"}
    end
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
    respond_to do |format|
      if @company.save
        CompanyUser.create(company: @company, user: current_user, admin: true, participation: true)
        current_user.update(company: true)
        Group.create(company: @company, user_id: current_user.id, cat: 2, name: @company.name)
        if current_user.cached_admin_company.size == 1
          # Btn next step appear
          @idz = 1
        end
        format.html { redirect_back }
        format.js { render "companies/js/create" }
      end
    end
  end

  def update
    respond_to do |format|
      if @company.update(company_params)
        @company.groups.first.update(name: @company.name)
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
