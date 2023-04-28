FactoryBot.define do
  factory :user do
        name{Faker::Name.name}
        sequence(:password){|n| "#{n}_#{Faker::Internet.password(min_length: 8)}"}
        sequence(:email){|n| "#{n}_#{Faker::Internet.email}"}

        trait :with_user_detail do
          # association :user_detail, factory: :user_detail
          user_detail
    end
  end
end
