class Subscription < ApplicationRecord
  belongs_to :subscribing_user, :class_name => "User"  # 구독자
  belongs_to :subscribed_user, :class_name => "User"  # 구독 받은 사람

  # check the uniqueness of a subscription from one to another
  validates :subscribing_user_id, uniqueness: { scope: :subscribed_user_id }

  # 한 사용자가 할 수 있는 구독의 수를 제한
  module SubscriptionLimit
    MAX_SUBSCRIPTION_NUMBER = 5
  end
end
