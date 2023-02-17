# frozen_string_literal: true

Rails.autoloaders.main.ignore(
  Rails.root.join('app/rails_admin_actions'),
  Rails.root.join('app/assets'),
  Rails.root.join('app/javascripts'),
  Rails.root.join('app/views')
)
