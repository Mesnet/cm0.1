class TasksController < ApplicationController
  before_action :set_task, except: [:create]

  # POST /tasks
  # POST /tasks.json
  def create
    respond_to do |format|
      @group = Group.find(params[:groupid])
      if @group.cached_users.include?(current_user)
        #Group Secure
        @task = Task.new(task_params)
        @task.group_id = @group.id
        @task.user_id = current_user.id
        if @task.save
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
              format.js {render 'posts/elm_new'}
              @element = Element.create(group: @group, user: current_user, cat: 3, task: @task)
            else
              #Task New
              format.js
            end
          end
        end
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :date, :important, :user_ids => [])
    end
end
