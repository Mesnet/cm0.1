class QuestionsController < ApplicationController
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
    @question = Question.new(question_params)
    respond_to do |format|
      if @question.save
        @element = Element.create(group_id: @question.group_id, user: current_user, cat: 2, question_id: @question.id)
        # Update Post
        if params[:postid]
          @new = false
          @post = Post.find(params[:postid])
          if @post.user.id == current_user.id
            @element.update(post_id: @post.id)
          end
        else
          @new = true
        end
        format.js { render 'questions/elm/create' }
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

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    def set_answer
      @answer = Answer.find(params[:qid])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :multiple, :group_id, answers_attributes: [:id, :title, :_destroy])
    end
end
