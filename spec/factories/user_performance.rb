FactoryBot.define do
  factory :user_performance do
    user { create :user }
    performance { create :performance, visible: true }
    contribution 'Performer'
    student_level 'Graduate'
    role_other nil
  end
end
