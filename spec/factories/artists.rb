FactoryGirl.define do
  factory :artist do
    sequence(:name) { |n| "Artist #{n}" }
    sequence(:slug) { |n| "artist-#{n}" }
  end
end