class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_save :allocate_access_token

  module ApiLevel
    DEFAULT = 0
    DASHBOARD = 1
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
