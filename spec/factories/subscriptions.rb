FactoryBot.define do
  factory :subscription do
    subscribing_user_id { 1 }
    subscribed_user_id { 1 }
  end
end
