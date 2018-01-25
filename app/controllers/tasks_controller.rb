class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :have_company, only: [:index]
  before_action :enable_nav, only: [:index]
  before_action :set_task, except: [:create, :index]
  before_action :group_autorization, only: [:done, :undone, :participate, :unparticipate, :post_change, :post_select, :create]
  before_action :adminitrator, only: [:delparticipate, :update, :destroy]
  after_action :upd_elements, except: [:create, :show_sn, :post_select, :post_select, :index]

  #JS Action
  def show_sn
    respond_to do |format|
      if @task.user_id == current_user.id
        @users =  [current_user] + (@task.group.cached_users - [current_user])
      end
      format.js { render 'tasks/sn/show' }
    end
  end

  def participate
    respond_to do |format|
      unless @task.cached_users.include?(current_user)
        @user = current_user
        @task.task_users.where(user: @user).first_or_create
        @task.update(effectif: (@task.effectif += 1))
        format.js { render 'tasks/js/participate' }
      else
        format.js {render inline: "location.reload();" }
      end
    end
  end

  def unparticipate
    respond_to do |format|
      if @task.cached_users.include?(current_user)
        @user = current_user
        @task.task_users.where(user: @user).delete_all
        @task.update(effectif: (@task.effectif -= 1))
        format.js { render 'tasks/js/unparticipate' }
      else
        format.js {render inline: "location.reload();" }
      end
    end
  end

  def delparticipate
    respond_to do |format|
      @user = User.find_by(id: params[:userid])
      if @task.cached_users.include?(@user)
        @task.task_users.where(user: @user).delete_all
        @task.update(effectif: (@task.effectif -= 1))
      end
      format.js { render 'tasks/js/unparticipate' }
    end
  end

  def done
    respond_to do |format|
      unless @task.done?
        #Prevent done again(if other user did it)
        @task.update(done: true, doner_id: current_user.id, done_at: Time.now)
        @task.task_reminds.update(deleted_state: true)
        format.js { render 'tasks/js/done' }
      end
      format.js {render inline: "location.reload();" }
    end
  end

  def undone 
    respond_to do |format|
      if @task.done?
        #Prevent undone again(if other user did it)
        @task.update(done: false, doner_id: nil, done_at: nil)
        @task.task_reminds.update(deleted_state: false)
        format.js { render 'tasks/js/done' }
      end
      format.js {render inline: "location.reload();" }
    end
  end 

  # Post
  def post_select
    respond_to do |format|
      @element = Element.create(group: @group, user: current_user, cat: 3, task: @task)
      format.js {render 'posts/elm_new'}
    end
  end 

  def post_change
    respond_to do |format|
      @element = Element.find(params[:elmid])
      if @element.user == current_user
        #Element Secure
        @element.update(task_id: @task.id)
        if @element.post.present?
          @element.post.update(upd_at: Time.now, upd_title: 'a modifier un élément')
        end
        format.js {render 'posts/elm_upd'}
      end
    end
  end

  # Basics
  def index
  end

  def create
    respond_to do |format|
      @task = Task.new(task_params)
      @task.group_id = @group.id
      @task.user_id = current_user.id
      if @task.save
        # Create a new initial post
        @new_post = Post.create(user: current_user, group: @group, upd_at: Time.now, cat: 1, upd_title: 'a créer une nouvelle tâche')
        @element = Element.create(group: @group, user: current_user, cat: 3, task: @task, post: @new_post)
        if @task.important?
          @task.update(priority: 1)
        else 
          if @task.date.present?
            @task.update(priority: 2)
          end
        end
        if params[:postid]
          # PostUpdate
          @post = Post.find(params[:postid])
          if @post.user = current_user
            #Post Secure
            @element = Element.create(group: @group, user: current_user, cat: 3, task: @task, post: @post)
            format.js {render 'posts/elm_new'}
          end
        else
          if params[:post]
            #Post New
            @element = Element.create(group: @group, user: current_user, cat: 3, task: @task)
            format.js {render 'posts/elm_new'}
          else
            #Task New
            format.js
          end
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        if @task.important?
          @task.update(priority: 1)
        else 
          if @task.date.present?
            @task.update(priority: 2)
          else
            @task.update(priority: 3)
          end
        end
        @elements = @task.elements 
        format.js { render 'tasks/js/update' }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @post = @task.posts.last
    @elements = @task.elements.map(&:id) 
    @task.elements.delete_all
    @task.task_users.delete_all
    @post.destroy
    @task.destroy
    @task.posts.update(updated_at: Time.now)
    respond_to do |format|
      format.js { render 'tasks/js/destroy' }
    end
  end

  private

    def set_task
      @task = Task.find(params[:id])
    end

    def group_autorization
      if params[:groupid]
        @group = Group.find(params[:groupid])
      else
        @group = @task.group
      end
      unless @group.cached_users.include?(current_user)
        respond_to do |format|
          redirect_to root_path
          # Vous ne faites pas parti de ce groupe
        end
      end
    end

    def adminitrator
      unless @task.user_id == current_user.id
        respond_to do |format|
          format.js {render inline: "location.reload();" }
          # Vous n'avez pas l'autorization pour cet action
        end
      end
    end

    def upd_elements
      if @task.elements.any?
        @task.elements.update(updated_at: Time.now)
      end
    end

    def task_params
      params.require(:task).permit(:title, :date, :important, :user_ids => [])
    end

    def enable_nav
      @enable_nav = true
    end
end
