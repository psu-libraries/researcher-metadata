# frozen_string_literal: true

class ActivityInsightExporter
  private

    def auth
      {
        username: Settings.activity_insight.username,
        password: Settings.activity_insight.password
      }
    end

    def webservice_url
      # Url is defined in the child class
    end
end
