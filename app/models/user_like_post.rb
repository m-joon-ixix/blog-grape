class UserLikePost < ApplicationRecord
  belongs_to :user
  belongs_to :post

  def post_title
    post.title
  end

  def user_name
    user.user_name
  end
end
