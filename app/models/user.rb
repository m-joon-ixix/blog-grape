class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :validatable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_like_posts, dependent: :destroy
  has_many :user_like_comments, dependent: :destroy

  before_create :allocate_default_api_level
  before_save :allocate_access_token

  module ApiLevel
    DEFAULT = 0
    DASHBOARD = 1
  end

  def is_admin?
    self.api_level == ApiLevel::DASHBOARD
  end

  def allocate_default_api_level
    self.api_level = ApiLevel::DEFAULT if self.api_level.nil?
  end

  def allocate_access_token
    self.access_token ||= loop do
      random_token = SecureRandom.urlsafe_base64(32, false)
      break random_token unless self.class.exists?(access_token: random_token)
    end
  end

  def regenerate_token!
    self.access_token = nil
    self.save  # allocates token before_save
  end

end
