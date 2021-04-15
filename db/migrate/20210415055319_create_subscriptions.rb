class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.integer :subscribing_user_id
      t.integer :subscribed_user_id

      t.timestamps
    end
  end
end
