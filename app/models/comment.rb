class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  # relationship with Post
  after_create :increment_num_of_comments
  before_destroy :decrement_num_of_comments

  # returns the comments that can be deleted by a user with 'current_user_id'
  scope :able_to_delete, -> (current_user_id) {
    joins(:post).where("posts.user_id = ? OR comments.user_id = ?", current_user_id, current_user_id)
  }

  def user_name
    user.user_name
  end

  def increment_num_of_comments
    post.num_of_comments += 1
    post.save
  end

  def decrement_num_of_comments
    post.num_of_comments -= 1
    post.save
  end

end
