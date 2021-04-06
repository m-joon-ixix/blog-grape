class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  belongs_to :user
  belongs_to :category

  validates :title, presence: true, length: { minimum: 5 }
  validates :body, presence: true

  def user_name
    # User.find(user_id) -> 아랫줄의 user로 찾을 수 있음, 콜 할때마다 DB를 매번 찌른다.
    user.user_name # 이렇게 하면 (belongs_to method의 기능) DB를 처음 한번만 찌른다. (caching)
  end
end
