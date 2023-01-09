# frozen_string_literal: true

FactoryBot.define do
  factory :user_performance do
    user { create(:user) }
    performance { create(:performance, visible: true) }
    contribution { 'Performer' }
    student_level { 'Graduate' }
    role_other { nil }
    sequence(:activity_insight_id) { |n| n + 1000000000 }
  end
end
