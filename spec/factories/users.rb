require 'factory_girl'

FactoryGirl.define do

  factory :user do
    sequence(:email) { |n| "test#{n}@tempora.io" }
    password "password"
    first_name "first"
    last_name "last"
  end

  factory :following do
    user
    artist
  end

end