class CommentsController < ApplicationController
  before_action :set_commentable, only: [:create]

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.created_by = current_user.email

    if @comment.save
      redirect_to_commentable(notice: "Comment added.")
    else
      redirect_to_commentable(alert: "Failed to add comment.")
    end
  end

  private

  def set_commentable
    params.each do |key, value|
      next unless key.to_s =~ /(.+)_id$/
  
      basename = $1.classify  # e.g. "Equipment", "Chemical"
      klass = basename.safe_constantize
  
      # Try Inventory namespace since routes are nested under inventory
      if klass.nil?
        klass = "Inventory::#{basename}".safe_constantize
      end
  
      # Fallback: search for namespaced constants in other namespaces
      if klass.nil?
        klass = ObjectSpace.each_object(Class).find do |c|
          c.name&.end_with?("::#{basename}")
        end
      end
  
      return @commentable = klass.find(value) if klass
    end
  
    raise "Commentable not found"
  end
  
  def comment_params
    params.require(:comment).permit(:body)
  end


  def redirect_to_commentable(flash_hash = {})
    redirect_to polymorphic_url(@commentable, { tab: :comments }), flash: flash_hash
  end
end