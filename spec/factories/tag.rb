FactoryBot.define do
  factory :tag do
    sequence :name do |n|
      "abc#{n}"
    end
  end
end
