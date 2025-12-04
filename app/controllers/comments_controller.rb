class CommentsController < ApplicationController
  before_action :find_comment, only: [:update]
  before_action :authorize_comment_edit, only: [:update]

  def create
    commentable = find_polymorphic_parent
    @comment = commentable.comments.new(comment_params)
    @comment.created_by = current_user.email

    if @comment.save
      redirect_to_polymorphic_parent(commentable, tab: :comments, flash_hash: { notice: "Comment added." })
    else
      redirect_to_polymorphic_parent(commentable, tab: :comments, flash_hash: { alert: "Failed to add comment." })
    end
  end

  def update
    commentable = @comment.commentable

    if @comment.update(comment_params)
      redirect_to_polymorphic_parent(commentable, tab: :comments, flash_hash: { notice: "Comment updated." })
    else
      redirect_to_polymorphic_parent(commentable, tab: :comments, flash_hash: { alert: "Failed to update comment." })
    end
  end

  private

  def find_comment
    commentable = find_polymorphic_parent
    @comment = commentable.comments.find(params[:id])
  end

  def authorize_comment_edit
    unless @comment.created_by == current_user.email
      commentable = @comment.commentable
      redirect_to_polymorphic_parent(commentable, tab: :comments, flash_hash: { alert: "You can only edit your own comments." })
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end