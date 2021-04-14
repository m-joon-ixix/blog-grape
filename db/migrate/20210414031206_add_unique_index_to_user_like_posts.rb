class AddUniqueIndexToUserLikePosts < ActiveRecord::Migration[5.1]
  def change
    add_index :user_like_posts, [:user_id, :post_id], unique: true
  end
end
