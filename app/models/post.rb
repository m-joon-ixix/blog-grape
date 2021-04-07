class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  belongs_to :user
  belongs_to :category

  validates :title, presence: true, length: { minimum: 5 }
  validates :body, presence: true
  validates :user_id, presence: true
  validates :num_of_comments, numericality: { greater_than_or_equal_to: 0 }

  # relationship with Category
  after_create :increment_num_of_posts
  before_destroy :decrement_num_of_posts

  # relationship with comments
  before_validation :initialize_num_of_comments, on: :create

  def user_name
    # User.find(user_id) -> 아랫줄의 user로 찾을 수 있음, 콜 할때마다 DB를 매번 찌른다.
    user.user_name # 이렇게 하면 (belongs_to method의 기능) DB를 처음 한번만 찌른다. (caching)
  end

  def increment_num_of_posts
    category.num_of_posts += 1
    category.save
  end

  def decrement_num_of_posts
    category.num_of_posts -= 1
    category.save
  end

  def initialize_num_of_comments
    self.num_of_comments = 0
  end

end
