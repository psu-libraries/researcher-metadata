FactoryBot.define do
  factory :publication do
    sequence(:title) { |sn| "Publication ##{sn}" }
  end
end
