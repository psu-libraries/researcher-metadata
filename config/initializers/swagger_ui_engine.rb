SwaggerUiEngine.configure do |config|
  config.swagger_url = {
    v1: 'swagger.json'
  }
  config.validator_enabled = {
    validator_url: nil
  }
end
