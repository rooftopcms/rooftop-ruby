module Rooftop
  module Client
    def self.included(base)
      if Rooftop.configuration.url.nil?
        raise ArgumentError, "You need to configure Rooftop before instantiating a class with a Rooftop mixin"
      end

      Her::API.setup url: Rooftop.configuration.url do |c|
        #Headers
        c.use Rooftop::Headers

        # Request
        c.use Faraday::Request::UrlEncoded

        # Response
        c.use Her::Middleware::DefaultParseJSON

        # Adapter
        c.use Faraday::Adapter::NetHttp
      end
      base.include Her::Model
    end
  end
end