class UserLikeComment < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  # Check the uniqueness of the (User, Comment) combination
  validates :user_id, uniqueness: { scope: :comment_id }

  def post_id_of_comment
    comment.post.id
  end

  def user_name
    user.user_name
  end
end
