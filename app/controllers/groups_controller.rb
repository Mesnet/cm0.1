class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :have_company, only: [:index, :show, :taskboard, :calendar, :cloud]
  before_action :enable_nav, only: [:index, :show, :taskboard, :calendar, :cloud]
  before_action :company_autorization, only: [:create]
  before_action :set_group, except: [:index, :show_new_group, :show_more_group, :show_fav_group, :create]
  before_action :autorization, except: [:index, :show_new_group, :show_more_group, :create, :join, :unjoin, :show_fav_group, :acc_invit, :den_invit]
  before_action :aministrator, only: [:update, :destroy, :upd_role]


  #New
    def show_new_group
      @companies = current_user.companies
      respond_to do |format|
        format.js { render 'groups/new/show' }
      end
    end

    def create 
      @group = Group.new(group_params)
      @group.update(user_id: current_user.id)
      if @group.save
        respond_to do |format|
          format.js { render 'groups/new/create' }
        end
      end
    end

  #Fav
    def fav
      respond_to do |format|
        @group.group_users.where(user: current_user).update(favorit: true)
        @idz = 1
        format.js {render 'groups/fav/respond'}
      end
    end

    def unfav
      respond_to do |format|
        @group.group_users.where(user: current_user).update(favorit: false)
        @idz = 2  
        format.js {render 'groups/fav/respond'}
      end
    end

    def show_fav_group
      respond_to do |format|
        format.js { render 'groups/fav/show' }
      end
    end
  
  private

  def company_autorization
    company = current_user.companies.find(params[:group][:company_id])
    unless company.cached_users.include?(current_user)
      redirect_to root_path
      # Vous ne faites pas partit de cette companie
    end 
  end

  def autorization
    unless @group.cached_users.include?(current_user)
      redirect_to root_path
      # Vous ne faites pas partit de ce groupe
    end
  end


  def set_group
    @group = Group.find(params[:id])
    if @group == nil
      redirect_to root_path
    end
  end

  def group_params
    params.require(:group).permit(:name, :cat, :creator_id, :effectif, :pend_req, :description, :company_id, :open, :user_ids => [])
  end

  def enable_nav
    @enable_nav = true
  end
  
end
