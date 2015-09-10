module RooftopRubyClient
  module Client
    def self.included(base)
      if RooftopRubyClient.configuration.url.nil?
        raise ArgumentError, "You need to configure RooftopRubyClient before instantiating a class with a RooftopRubyClient mixin"
      end

      Her::API.setup url: RooftopRubyClient.configuration.url do |c|
        #Headers
        c.use RooftopRubyClient::Headers

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