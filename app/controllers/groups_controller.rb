class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :have_company, only: [:index, :show, :taskboard]
  before_action :enable_nav, only: [:index, :show, :taskboard, :calendar, :cloud]
  before_action :set_group, except: [:index, :show_new_group, :show_more_group, :show_fav_group, :create]
  before_action :autorization, except: [:index, :show_new_group, :show_more_group, :create, :join, :unjoin, :show_fav_group, :acc_invit, :den_invit]
  before_action :aministrator, only: [:update, :destroy, :upd_role]
  before_action :set_user, only: [:expel, :invit, :uninvit, :accept_req, :denie_req, :upd_role]
  before_action :last_request, only: [:accept_req, :denie_req]
  before_action :last_invit, only: [:acc_invit, :den_invit]
  before_action :last_group, only: [:join]

  #Action for create
  

  private

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
