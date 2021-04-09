class Category < ApplicationRecord
  has_many :posts

  validates :name, presence: true
  validates :num_of_posts, numericality: { greater_than_or_equal_to: 0 }

  before_validation :initialize_num_of_posts, on: :create
  before_destroy :eliminate_category_from_posts

  def initialize_num_of_posts
    self.num_of_posts = 0
  end

  # when destroying the category, leave the posts and only change their categories to 'others'
  def eliminate_category_from_posts
    posts.each do |post|
      post.change_category(0)  # category.find(0) : others category
    end
  end

end

