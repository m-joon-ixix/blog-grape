class AddVisibilityToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :visibility, :integer, default: 0
  end
end
