class QuestionsController < ApplicationController
  before_action :set_question, only: [:update, :destroy]

  def create
    @question = Question.new(question_params)
    respond_to do |format|
      if @question.save
        @element = Element.create(group_id: @question.group_id, user: current_user, cat: 2, question_id: @question.id)
        # New Post
        @idz = 1
        # Update Post
        if params[:postid]
          @post = Post.find(params[:postid])
          if @post.id == current_user.id
            @element.update(post_id: params[:postid])
          end
          @idz = 2
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

  # DELETE /questions/1
  # DELETE /questions/1.json
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :voters, :multiple, :group_id, answers_attributes: [:id, :title, :vote, :_destroy])
    end
end
