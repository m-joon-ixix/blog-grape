class UserLikePost < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # check the uniqueness of the (User, Post) combination
  validates :user_id, uniqueness: { scope: :post_id }

  def post_title
    post.title
  end

  def user_name
    user.user_name
  end
end
