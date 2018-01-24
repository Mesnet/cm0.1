class SubTasksController < ApplicationController
  before_action :set_sub_task, only: [:update, :destroy, :done, :undone]
  before_action :set_task, only: [:update, :destroy, :done, :undone]

  def done
    @sub_task.update(done: true, doner_id: current_user.id, done_at: Time.now)
    @task.update(st_d: (@task.st_d += 1))
    respond_to do |format|
      format.html { redirect_back }
      format.js
    end
  end

  def undone 
    @sub_task.update(done: false, doner_id: nil, done_at: nil)
    @task.update(st_d: (@task.st_d -= 1))
    respond_to do |format|
      format.html { redirect_back }
      format.js { render 'done' }
    end 
  end 

  def create
    @sub_task = SubTask.new(sub_task_params)
    @task = @sub_task.task
    @task.update(st_n: (@task.st_n += 1))
    @sub_task.update(user_id: current_user.id)
    respond_to do |format|
      if @sub_task.save && @sub_task.title.present?
        format.html { redirect_back }
        format.js 
      else
        @sub_task.destroy
        format.html { render :new }
        format.json { render json: @sub_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sub_tasks/1
  # PATCH/PUT /sub_tasks/1.json
  def update
    respond_to do |format|
      if @sub_task.update(sub_task_params)
        format.html { redirect_back }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @sub_task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sub_tasks/1
  # DELETE /sub_tasks/1.json
  def destroy
    @task.update(st_n: (@task.st_n -= 1))
    if @sub_task.done?
      @task.update(st_d: (@task.st_d -= 1))
    end
    @sub_task.destroy
    respond_to do |format|
      format.html { redirect_back }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sub_task
      @sub_task = SubTask.find(params[:id])
    end

    def set_task
      @task = @sub_task.task
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sub_task_params
      params.require(:sub_task).permit(:title, :done, :task_id, :user_id, :done_at, :doner_id)
    end
end
