FactoryBot.define do
  factory :post do
    title { "MyString" }
    body { "MyText" }
    user_id { 1 }
    category_id { 1 }
  end
end
