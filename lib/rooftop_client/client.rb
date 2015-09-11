module RooftopClient
  module Client
    def self.included(base)
      if RooftopClient.configuration.url.nil?
        raise ArgumentError, "You need to configure RooftopClient before instantiating a class with a RooftopClient mixin"
      end

      Her::API.setup url: RooftopClient.configuration.url do |c|
        #Headers
        c.use RooftopClient::Headers

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