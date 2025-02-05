# frozen_string_literal: true

module Utilities
  class WorksGenerator
    def initialize(webaccess_id)
      raise 'Cannot generate publications in the production environment' if Rails.env.production?

      @user = User.find_by(webaccess_id: webaccess_id) || FactoryBot.create(:sample_user, webaccess_id: webaccess_id)
    end

    def oa_publication_no_open_access_location
      FactoryBot.create :sample_publication, :oa_publication, :from_pure, user: user
    end

    def oa_publication_with_open_access_location
      FactoryBot.create :sample_publication, :oa_publication, :from_pure, :with_open_access_location, user: user
    end

    def oa_publication_in_press
      FactoryBot.create :sample_publication, :oa_publication, :from_pure, :in_press, user: user
    end

    def oa_publication_from_activity_insight
      FactoryBot.create :sample_publication, :oa_publication, :from_activity_insight, user: user
    end

    def oa_publication_duplicate_group
      FactoryBot.create :sample_publication, :oa_publication, :from_pure, :with_duplicate_group, user: user
    end

    def oa_publication_non_duplicate_group
      FactoryBot.create :sample_publication, :oa_publication, :from_pure, :with_non_duplicate_group, user: user
    end

    def other_work
      FactoryBot.create :sample_publication, :other_work, :from_pure, user: user
    end

    def presentation
      FactoryBot.create :sample_presentation, user: user
    end

    def performance
      FactoryBot.create :sample_performance, user: user
    end

    private

      attr_accessor :user
  end
end
