module RooftopClient
  class Headers < Faraday::Middleware
    def call(env)
      unless RooftopClient.configuration.api_token.nil?
        env[:request_headers]["API-TOKEN"] = RooftopClient.configuration.api_token
      end

      RooftopClient.configuration.extra_headers.each do |key,value|
        env[:request_headers][key.to_s] = value
      end
      env[:request_headers]["User-Agent"] = RooftopClient.configuration.user_agent
      @app.call(env)
    end
  end
end
