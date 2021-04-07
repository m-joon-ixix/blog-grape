class AddNumOfCommentsToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :num_of_comments, :integer
  end
end
