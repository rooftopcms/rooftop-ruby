# Code courtesty https://github.com/envylabs/faraday-detailed_logger - MIT licence

module Rooftop
  class DebugMiddleware < Faraday::Response::Middleware

    def self.default_logger
      require "logger"
      ::Logger.new(STDOUT)
    end

    # Public: Initialize a new Logger middleware.
    #
    # app - A Faraday-compatible middleware stack or application.
    # logger - A Logger-compatible object to which the log information will
    #          be recorded.
    # progname - A String containing a program name to use when logging.
    #
    # Returns a Logger instance.
    #
    def initialize(app, logger = nil, progname = nil)
      super(app)
      @logger = logger || self.class.default_logger
      @progname = progname
    end


    def call(env)
      if Rooftop.debug_requests
        @logger.info(@progname) { "#{env[:method].upcase} #{env[:url]}" }
        @logger.debug(@progname) { curl_output(env[:request_headers], env[:body]).inspect }
      end
      super
    end

    def on_complete(env)
      if Rooftop.debug_responses
        status = env[:status]
        log_response_status(@progname, status) { "HTTP #{status}" }
        @logger.debug(@progname) { curl_output(env[:response_headers], env[:body]).inspect }
      end
    end

    private
    def curl_output(headers, body)
      string = headers.collect { |k,v| "#{k}: #{v}" }.join("\n")
      string + "\n\n#{body}"
    end

    def log_response_status(progname, status, &block)
      case status
        when 200..399
          @logger.info(progname, &block)
        else
          @logger.warn(progname, &block)
      end
    end

  end

end