module RooftopRubyClient
  class Headers < Faraday::Middleware
    def call(env)
      unless RooftopRubyClient.configuration.api_token.nil?
        env[:request_headers]["X-API-Token"] = RooftopRubyClient.configuration.api_token
      end

      RooftopRubyClient.configuration.extra_headers.each do |key,value|
        env[:request_headers][key.to_s] = value
      end
      @app.call(env)
    end
  end
end
