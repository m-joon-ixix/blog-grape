class AddNumOfPostsToCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :num_of_posts, :integer
  end
end
