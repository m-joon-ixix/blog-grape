class UserLikeComment < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  def post_id_of_comment
    comment.post.id
  end

  def user_name
    user.user_name
  end
end
