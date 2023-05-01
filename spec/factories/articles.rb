FactoryBot.define do
  factory :article do
    title{Faker::Lorem.word}
    body{Faker::Lorem.sentence}
    # user_id{1}
    user

  #       trait :with_user_detail do
  #         user_details
  end
end
