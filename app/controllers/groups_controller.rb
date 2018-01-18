class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :have_company, only: [:index, :show, :taskboard, :calendar, :cloud]
  before_action :enable_nav, only: [:index, :other_groups, :other_groups_out, :show, :taskboard, :calendar, :cloud]
  before_action :my_other_groups, only: [:other_groups , :other_groups_out]
  before_action :set_group, except: [:index, :show_new_group, :other_groups, :other_groups_out, :show_fav_group, :create]
  before_action :autorization, except: [:index, :show_new_group, :other_groups, :other_groups_out, :show_fav_group, :create, :join, :unjoin, :acc_invit, :den_invit]
  before_action :aministrator, only: [:update, :destroy, :expel, :upd_role, :acc_req, :den_req, :invit, :uninvit]
  before_action :set_user, only: [:expel, :upd_role, :acc_req, :den_req, :invit, :uninvit]

  #Other
    def other_groups
      @groups = @groups_in
      render "groups/other/private"
    end

    def other_groups_out
      @groups = (Group.findable) - @groups_in - @my_groups
      render "groups/other/public"
    end

    def join
      respond_to do |format|
        @gu = @group.group_users.where(user: current_user).first_or_create
        if @group.cat == 3
        # Group open
        @gu.update(invitation: false, participation: true)
        @group.update(effectif: (@group.effectif += 1))
        format.js { render 'groups/other/join' }
        else
        # Group closed
          if @gu.invitation?
            #User already invited
            @gu.update(invitation: false, participation: true)
            @group.update(effectif: (@group.effectif += 1))
            current_user.update(pend_invit: (current_user.pend_invit -= 1))
            format.js { render 'groups/other/join' }
          else
            #User not invited -> Send a request
            @gu.update(request: true)
            @group.update(pend_req: (@group.pend_req += 1))
            format.js { render 'groups/other/update' }
          end
        end
      end
    end

    def unjoin
      if @group.cached_users.include?(current_user)
        # Already accepted into the group
        @group.update(effectif: (@group.effectif -= 1))
      end
      @gu = @group.group_users.where(user: current_user).update(participation: false, request: false, invitation: false)
      respond_to do |format|
        format.js { render 'groups/other/update' }
      end
    end

  #Edit
    def editor
      if [3, 4, 5].include?(@group.cat)
        respond_to do |format|
          @users = [current_user] + ( @group.cached_admins - [current_user] ) + (@group.cached_users  - @group.cached_admins - [current_user])
          if @group.company.present?
            @invitations = @group.cached_requests + @group.cached_invitations + (@group.company.cached_users - @group.cached_requests - @group.cached_invitations - @users )
          else 
            # Select the contacts of current_user
            @invitations = @users - @users
          end
          format.js { render 'groups/edit/show' }
        end
      end
    end

    def update
      if @group.update(group_params)
        respond_to do |format|
          format.js { render 'groups/edit/update'}
        end
      end
    end

    def quit
      respond_to do |format|
        if @group.cached_admins.include?(current_user) && @group.cached_admins.size == 1
          format.js { render 'groups/js/error_admin'}
        else
          if @group.cached_users.include?(current_user)
            @group.group_users.where(user: current_user).update(participation: false, admin: false)
            @group.update(effectif: (@group.effectif -= 1))
          end
          format.js { render 'groups/js/destroy'}
        end
      end
    end

    def expel
      respond_to do |format|
        if @group.cached_users.include?(@user)
          @group.group_users.where(user: @user).update(participation: false, admin: false)
          @group.update(effectif: (@group.effectif -= 1))
        end
        format.js { render 'groups/js/expel'}
      end
    end

    def upd_role
      respond_to do |format|
        if @user.id == current_user.id && @group.cached_admins.size == 1
          format.js { render 'groups/js/error_admin'}
        else
          @cu = @group.group_users.where(user: @user)
          if params[:admin]
            @cu.update(admin: true)
          else
            @cu.update(admin: false)
          end
          if @user.id == current_user.id
            format.js {render inline: "location.reload();" }
          else 
            format.js { render "groups/edit/upd_role"}
          end
        end
      end
    end

  #Invit
    def acc_req
      respond_to do |format|
        if @group.cached_requests.include?(@user)
          # Request is still waiting
          @group.group_users.where(user: @user).update(request: false, participation: true)
          @idz = 1
          @group.update(effectif: (@group.effectif += 1), pend_req: (@group.pend_req -= 1))
        end
        format.js { render 'groups/js/invit'}
      end
    end

    def den_req
      respond_to do |format|
        if @group.cached_requests.include?(@user)
          # Request is still waiting
          @group.group_users.where(user: @user).update(request: false)
          @group.update(pend_req: (@group.pend_req -= 1))
        end
        format.js { render 'groups/js/invit'}
      end
    end

    def invit
      respond_to do |format|
        if @group.cached_requests.include?(@user)
        #User already send a request => Accept it
          @gu = @group.group_users.where(user: @user).first_or_create
          @gu.update(request: false, participation: true)
          @group.update(effectif: (@group.effectif += 1))
          @idz = 1
        else
          unless @group.cached_users.include?(@user) || @group.cached_invitations.include?(@user)
          #User was not already accepted
            @gu = @group.group_users.where(user: @user).first_or_create
            @gu.update(invitation: true)
            @user.update(pend_invit: (@user.pend_invit += 1))
          else 
            @idz = 1
          end
        end
        format.js { render 'groups/js/invit'}
      end
    end 

    def uninvit
      respond_to do |format|
        if @group.cached_invitations.include?(@user)
          @group.group_users.where(user: @user).update(invitation: false)
          @user.update(pend_invit: (@user.pend_invit -= 1))
        else 
          @idz = 1
        end
        format.js { render 'groups/js/invit'}
      end
    end

    def acc_invit
      respond_to do |format|
        if @group.cached_invitations.include?(current_user)
          @group.group_users.where(user: current_user).update(invitation: false, participation: true)
          @group.update(effectif: (@group.effectif += 1))
          current_user.update(pend_invit: (current_user.pend_invit -= 1))
          @idz = 1
        end
        format.js { render 'pages/invit/respond'}
      end
    end

    def den_invit
      respond_to do |format|
        if @group.cached_invitations.include?(current_user)
          @group.group_users.where(user: current_user).update(invitation: false)
          current_user.update(pend_invit: (current_user.pend_invit -= 1))
        end
        format.js { render 'pages/invit/respond'}
      end
    end

  #New
    def show_new_group
      @companies = current_user.companies
      respond_to do |format|
        format.js { render 'groups/new/show' }
      end
    end

    def create
      respond_to do |format|
        @group = Group.new(group_params)
        if @group.company.present?
          unless @group.company.cached_users.include?(current_user)
            @group.destroy
          end
        end
        @group.update(user_id: current_user.id)
        if @group.save
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

  #Basics

    def show 
    end

    def destroy
      @group.destroy
      respond_to do |format|
        format.js { render 'groups/js/destroy' }
      end
    end
  
  private

    def my_other_groups
      @companies = current_user.companies
      @my_groups = current_user.favgroups + current_user.unfavgroups + current_user.cached_group_invitations
      @groups_in = Group.where(company: @companies).findable - @my_groups
    end

    def autorization
      unless @group.cached_users.include?(current_user)
        redirect_to root_path
        # Vous ne faites pas partit de ce groupe
      end
    end

    def aministrator
      unless @group.cached_admins.include?(current_user)
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

    def set_user
      @user = User.find(params[:userid])
    end

    def group_params
      params.require(:group).permit(:name, :cat, :description, :company_id)
    end

    def enable_nav
      @enable_nav = true
    end
  
end