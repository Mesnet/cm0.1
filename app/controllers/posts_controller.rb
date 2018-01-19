class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:update, :destroy]

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @group = @post.group
    respond_to do |format|
      if @post.save
        @post.group.elements.empty.update(post_id: @post.id)
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.js
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:group_id, :content)
    end
end
