module Rooftop
  class Headers < Faraday::Middleware
    def call(env)
      unless Rooftop.configuration.api_token.nil?
        env[:request_headers]["Api-Token"] = Rooftop.configuration.api_token
      end

      if Rooftop.preview
        env[:request_headers]['preview'] = "true"
      end

      Rooftop.configuration.extra_headers.each do |key,value|
        env[:request_headers][key.to_s] = value
      end
      env[:request_headers]["User-Agent"] = Rooftop.configuration.user_agent
      @app.call(env)
    end
  end
end
