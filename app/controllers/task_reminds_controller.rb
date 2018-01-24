class TaskRemindsController < ApplicationController
  before_action :set_remind, except: [:create]
  before_action :set_task, except: [:create]

  def create
    @remind = TaskRemind.new(remind_params)
    @task = @remind.task
    @remind.update(user_id: current_user.id)
    unless @remind.date.present?
      @remind.update(date: Time.now)
    end
    if @remind.save
      @task.update(updated_at: Time.now)
      current_user.update(updated_at: Time.now)
      respond_to do |format|
        format.html { redirect_back }
        format.js
      end 
    end
  end

  def update
    unless @remind.date.present?
      @remind.update(date: Time.now)
    end
    if @remind.update(remind_params)
      @task.update(updated_at: Time.now)
      current_user.update(updated_at: Time.now)
      respond_to do |format|
        format.js { render 'update' }
      end 
    end
  end

  def destroy
    @remind.destroy
    respond_to do |format|
      format.html { redirect_back }
      format.js
    end 
  end

  private
    def set_remind
      @remind = TaskRemind.find(params[:id])
    end

    def set_task
      @task = @remind.task
    end

    def remind_params
      params.require(:task_remind).permit(:task_id, :user_id, :date)
    end
end