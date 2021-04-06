class AddApiLevelToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :api_level, :integer, default: 0, null: false
  end
end
