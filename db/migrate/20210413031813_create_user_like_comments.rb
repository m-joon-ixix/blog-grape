class CreateUserLikeComments < ActiveRecord::Migration[5.1]
  def change
    create_table :user_like_comments do |t|
      t.integer :user_id
      t.integer :comment_id

      t.timestamps
    end
  end
end
