# frozen_string_literal: true

class DashboardCardComponent < ViewComponent::Base
  attr_reader :count, :title, :description, :path, :card_id

  def initialize(count:, title:, description:, path:, card_id:)
    @count = count
    @title = title
    @description = description
    @path = path
    @card_id = card_id
  end

  def render_link?
    count.nonzero?
  end

  def i18n(key, **)
    I18n.t("view_component.activity_insight_oa_dashboard_component.#{key}", **)
  end
end
