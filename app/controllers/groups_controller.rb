class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :have_company, only: [:index, :other_groups, :other_groups_out, :show, :taskboard, :calendar, :cloud]
  before_action :enable_nav, only: [:index, :other_groups, :other_groups_out, :show, :taskboard, :calendar, :cloud]
  before_action :my_other_groups, only: [:other_groups , :other_groups_out]
  before_action :set_group, except: [:index, :show_new_group, :create, :show_fav_group, :other_groups, :other_groups_out, :elm_upd, :elm_del]
  before_action :autorization, except: [:index, :create, :show_new_group, :show_fav_group, :join, :unjoin, :acc_invit, :den_invit, :other_groups, :other_groups_out, :elm_upd, :elm_del]
  before_action :aministrator, only: [:update, :destroy, :expel, :upd_role, :acc_req, :den_req, :invit, :uninvit]
  before_action :set_user, only: [:expel, :upd_role, :acc_req, :den_req, :invit, :uninvit]
  before_action :set_element, only: [:elm_upd, :elm_del]

  # Basics
  def show_done_tasks
    @tasks = @group.tasks.done
    respond_to do |format|
      format.js { render 'groups/js/show_tasks' }
    end
  end
  def index
  end

  def calendar
  end

  def cloud
  end

  def taskboard
    @users = @group.cached_users
    @tasks = @group.tasks.undone
  end

  #NewPostElements
  def new_element
    respond_to do |format|
      if params[:postid]
        @post = Post.find(params[:postid])
      else
        @post = nil
      end
      if params[:idz] == '1'
        format.js { render 'documents/elm/new' }
      elsif params[:idz] == '2'
        format.js { render 'questions/elm/new' }
      elsif params[:idz] == '3'
        unless @group.cat == 1
          @users = [current_user] +( @group.users - [current_user])
        end
        format.js { render 'tasks/elm/new' }
      elsif params[:idz] == '4'
        format.js { render 'events/elm/new' }
      end 
    end
  end

  def elm_upd
    respond_to do |format|
      if @element.cat == 1
        format.js { render 'documents/elm/update' }
      elsif @element.cat == 2
        @question = @element.question
        format.js { render 'questions/elm/update' }
      elsif @element.cat == 3
        @task = @element.task
        @group = @element.group
        if @element.post.present?
          @post = @element.post.id
        end
        format.js { render 'tasks/elm/update' }
      elsif @element.cat == 4
        format.js { render 'events/elm/update' }
      end 
    end
  end

  def elm_del
    if @element.cat == 2
      @element.question.destroy
    end
    if @element.post.present?
      @element.post.update(upd_at: Time.now, upd_title: "a supprimer un élément")
    end
    @element.destroy
    respond_to do |format|
      format.js { render 'posts/elm_del' }
    end
  end


  def show
    @elements = @group.elements.where(user: current_user).empty
    @posts = @group.posts
  end

  #Other
    def other_groups
      @groups = (Group.where(company: @companies).findable.search(params[:search]).order(effectif: :desc) - @my_groups).paginate(:per_page => 3, :page => params[:page])
      render "groups/other/private"
    end

    def other_groups_out
      @groups = ((Group.findable.search(params[:search]).order(effectif: :desc)) - Group.where(company: @companies).findable - @my_groups).paginate(:per_page => 3, :page => params[:page])
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
            #Company access secure
            if @group.company.present?
              unless @group.company.cached_users.include?(current_user)
                @gu.destroy
                @group.update(pend_req: (@group.pend_req -= 1))
              end
            end
            #/Company access secure
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
            @invitations = @group.cached_requests
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
        @req = 1
        if @group.pend_req == 0
          @req = 2
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
        @req = 1
        if @group.pend_req == 0
          @req = 2
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
            #Company access secure
            if @group.company.present?
              unless @group.company.cached_users.include?(@user)
                @gu.destroy
                @user.update(pend_invit: (@user.pend_invit -= 1))
              end
            end
            #/Company access secure
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
        #Company access secure
        if @group.company.present?
          unless @group.company.cached_users.include?(current_user)
            @group.destroy
          end
        end
        #/Company access secure
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

  #Delete

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

    def set_element
      @element = Element.find(params[:elmid])
      unless @element.user.id == current_user.id
        redirect_to root_path
      end
    end

    def group_params
      params.require(:group).permit(:name, :cat, :description, :company_id)
    end

end