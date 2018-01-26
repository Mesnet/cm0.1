class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :group_autorization, only: [:create]
  before_action :set_post, only: [:update, :destroy]
  before_action :authorization, only: [:update, :destroy]

  def create
    if params[:title] || params[:content] || @group.elements.empty
      @new_post = Post.new(post_params)
      @new_post.user = current_user
      @new_post.upd_at = Time.now
      @new_post.group = @group
      respond_to do |format|
        if @new_post.save
          @group.elements.empty.update(post_id: @new_post.id)
          format.js
        end
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

    def authorization
      unless @post.user == current_user
        redirect_to root_path
      end
    end
end
