class AddUniqueIndexToUserLikeComments < ActiveRecord::Migration[5.1]
  def change
    add_index :user_like_comments, [:user_id, :comment_id], unique: true
  end
end
