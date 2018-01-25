class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:update, :destroy]

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.upd_at = Time.now
    @group = @post.group
    respond_to do |format|
      if @post.save
        @post.group.elements.empty.update(post_id: @post.id)
        format.js
      end
    end
  end

  def update  
    @old_title = @post.title
    @old_content = @post.content
    if @post.update(post_params)
      if @old_title != @post.title || @old_content != @post.content
        @post.update(upd_at: Time.now, upd_title: 'a modifier le post')
      end
      @group = @post.group
      respond_to do |format|
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
      params.require(:post).permit(:group_id, :content, :title)
    end
end
