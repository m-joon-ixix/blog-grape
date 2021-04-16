class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :user_like_posts, dependent: :destroy
  belongs_to :user
  belongs_to :category

  validates :title, presence: true, length: { minimum: 5 }
  validates :body, presence: true
  validates :num_of_comments, numericality: { greater_than_or_equal_to: 0 }

  # relationship with Category
  after_create :increment_num_of_posts
  before_destroy :decrement_num_of_posts

  # relationship with comments
  before_validation :initialize_num_of_comments, on: :create

  # 0, 1, 2 values - default: 0 (public)
  module Visibility
    PUBLIC = 'public_post'
    SUBSCRIBE = 'subscriber_only'
    PRIVATE = 'private_post'
    ALL = [PUBLIC, SUBSCRIBE, PRIVATE]
  end

  enum visibility: Visibility::ALL

  # always use this when changing the category of a post
  # do not use Post.update(category_id: 000)
  def change_category(new_category_id)
    decrement_num_of_posts
    self.update(category_id: new_category_id)
    increment_num_of_posts
  end

  # @return Posts that 'current_user' can look at
  # @param [User] current_user
  def self.looked_by(current_user)
    public_posts = Post.where(visibility: Visibility::PUBLIC)
    my_posts = Post.where(user_id: current_user.id)
    # 'current_user'가 구독하는 사람이 작성한 게시글
    subscribing_posts = Post.where(visibility: Visibility::SUBSCRIBE,
                                   user_id: current_user.subscriptions.pluck(:subscribed_user_id))

    public_posts.or(my_posts).or(subscribing_posts)
  end

  # @return [Boolean] can user with 'current_user_id' see this post?
  # @param [Integer] current_user_id
  def able_to_see?(current_user_id)
    # if the author is current_user
    return true if user_id == current_user_id

    if visibility == 'public_post'
      true
    elsif visibility == 'private_post'
      false
    else
      # if the post is for subscriber only
      # 'current_user_id' must be subscribing 'user' (author of this post)
      user.inverse_subscriptions.pluck(:subscribing_user_id).include? current_user_id
    end
  end

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

  def num_of_likes
    user_like_posts.count
  end

  # @return [Integer] number of likes within the last 1 week
  def num_of_recent_likes
    user_like_posts.where("created_at > ?", 1.week.ago).count
  end

  # @return [Integer] number of comments within the last 1 week
  def num_of_recent_comments
    comments.where("created_at > ?", 1.week.ago).count
  end

  # @return [Integer] popularity based on recent likes and comments
  def compute_popularity
    2 * num_of_recent_likes + num_of_recent_comments
  end
end
