# frozen_string_literal: true

class WorksGenerator
  def initialize(webaccess_id)
    raise "Cannot generate publications in the production environment" if Rails.env.production?

    @user = User.find_by(webaccess_id: webaccess_id) || FactoryBot.create(:sample_user, webaccess_id: webaccess_id)
  end

  def journal_article_no_open_access_location
    FactoryBot.create :sample_publication, :journal_article, :from_pure, user: user
  end

  def journal_article_with_open_access_location
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :with_open_access_location, user: user
  end

  def journal_article_in_press
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :in_press, user: user
  end

  def journal_article_from_activity_insight
    FactoryBot.create :sample_publication, :journal_article, :from_activity_insight, user: user
  end

  def journal_article_duplicate_group
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :with_duplicate_group, user: user
  end

  def journal_article_non_duplicate_group
    FactoryBot.create :sample_publication, :journal_article, :from_pure, :with_non_duplicate_group, user: user
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
