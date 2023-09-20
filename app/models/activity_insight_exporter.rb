# frozen_string_literal: true

class ActivityInsightExporter
  private

    attr_accessor :target

    def auth
      {
        username: Settings.activity_insight.username,
        password: Settings.activity_insight.password
      }
    end

    def webservice_url
      case target
      when 'beta'
        'https://betawebservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      when 'production'
        'https://webservices.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-University'
      end
    end
end
