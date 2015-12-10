require 'rooftop'
Rooftop.configure do |config|
  config.url = "http://rooftop.rooftop-cms.dev"
  config.api_token = "e266fbdd1464980e8b9069b3fe3f71cd"
  config.api_path = "/wp-json"
  config.user_agent = "rooftop cms ruby client (http://github.com/rooftopcms/rooftop-ruby)"
end