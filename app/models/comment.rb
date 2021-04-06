class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  def user_name
    user.user_name
  end
end
