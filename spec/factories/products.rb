FactoryBot.define do
  factory :product do
    name { "MyString" }
    price { 1 }
    user { nil }
    record { nil }
  end
end