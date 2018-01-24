class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, except: [:create]
  before_action :set_answer, only: [:vote, :revote, :unvote]

    def vote
    Vote.create(user_id: current_user.id, question_id: @question.id, answer_id: @answer.id)
    @question.update(voters: (@question.voters += 1))
    @answer.update(vote: (@answer.vote += 1))
    respond_to do |format|
      format.js { render 'questions/vote' }
      ("<%= j render partial: 'posts/add/element_question', locals: {question: @question} %>");
    end
  end

  def revote
    if @question.multiple?
      Vote.create(user_id: current_user.id, question_id: @question.id, answer_id: @answer.id)
      @answer.update(vote: (@answer.vote += 1))
      @question.update(voters: (@question.voters += 1))
    else
      @previous_vote = Vote.where(user_id: current_user.id, question_id: @question.id).first
      @answer.update(vote: (@answer.vote += 1))
      @previous_vote.answer.update(vote: (@previous_vote.answer.vote -= 1))
      @previous_vote.update(answer_id: @answer.id) 
      @question.update(updated_at: Time.now)
    end
    respond_to do |format|
      format.js { render 'questions/vote' }
    end
  end
  # expire_fragment('all_available_products')

  def unvote
    Vote.where(user_id: current_user.id, question_id: @question.id, answer_id: @answer.id).delete_all
    @question.update(voters: (@question.voters -= 1))
    @answer.update(vote: (@answer.vote -= 1))
    respond_to do |format|
      format.js { render 'questions/vote' }
    end
  end

  def create
    @group = Group.find(params[:groupid])
    if @group.cached_users.include?(current_user)
      # Group Secure
      respond_to do |format|
        @question = Question.new(question_params)
        @question.group = @group
        if @question.save
          if params[:postid]
            # Post Update
            @post = Post.find(params[:postid])
            if @post.user = current_user
              # Post Secure
              @element = Element.create(group: @question.group, user: current_user, cat: 2, question: @question, post: @post)
            end
          else
            # Post New
            @element = Element.create(group: @question.group, user: current_user, cat: 2, question: @question)
          end
          format.js {render 'posts/elm_new'}
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @question.update(question_params)
        @element = @question.element
        format.js { render 'posts/elm_upd' }
      end
    end
  end

private

  def set_question
    @question = Question.find(params[:id])
  end

  def set_answer
    @answer = Answer.find(params[:qid])
  end

  def question_params
    params.require(:question).permit(:title, :multiple, answers_attributes: [:id, :title, :_destroy])
  end
  
end
