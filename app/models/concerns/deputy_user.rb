# frozen_string_literal: true

module DeputyUser
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/InverseOf
    belongs_to :deputy,
               class_name: 'User',
               foreign_key: :deputy_user_id,
               optional: true
    # rubocop:enable Rails/InverseOf
  end
end
