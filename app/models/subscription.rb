class Subscription < ApplicationRecord
  belongs_to :subscribing_user, :class_name => "User"  # 구독자
  belongs_to :subscribed_user, :class_name => "User"  # 구독 받은 사람
end
