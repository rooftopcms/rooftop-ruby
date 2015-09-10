require 'her'
require 'require_all'
require_rel '.'

require "active_support/all"

module RooftopRubyClient
  class << self
    #accessor to set the preview API for use instead of the production one
    attr_accessor :use_preview_api

    #access the configuration class as RooftopRubyClient.configuration
    attr_accessor :configuration

    #block for configuration.
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
      self.configuration.configure_connection
    end

  end

  class Configuration
    attr_accessor :api_token, :url, :extra_headers
    attr_reader :connection

    def initialize
      @extra_headers ||= []
      @connection ||= Her::API.new
    end

    # Return the Configuration object as a hash, with symbols as keys.
    # @return [Hash]
    def to_hash
      Hash[instance_variables.map { |name| [name.to_s.gsub("@","").to_sym, instance_variable_get(name)] } ]
    end

    def configure_connection
      if @url.nil?
        raise ArgumentError, "You need to configure RooftopRubyClient before instantiating a class with a RooftopRubyClient mixin"
      end

      @connection.setup url: @url do |c|
        #Headers
        c.use RooftopRubyClient::Headers

        # Request
        c.use Faraday::Request::UrlEncoded

        # Response
        c.use Her::Middleware::DefaultParseJSON

        # Adapter
        c.use Faraday::Adapter::NetHttp
      end
    end
  end
end
