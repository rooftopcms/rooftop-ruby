module Rooftop
  class PaginationMiddleware < Faraday::Response::Middleware
    def on_complete(env)
      @env = env

      pagination = {
          total_count: header("x-wp-total").to_i,
          total_pages: header("x-wp-totalpages").to_i,
          per_page:    (header("x-wp-per-page").to_i || 10),
          page:        header("x-wp-page").to_i || 1
      }

      env[:body][:metadata].merge!(pagination: pagination)
    end

    private

    # Returns a response header value.
    #
    # @param [String] name of the header attribute
    # @return [String] the response header value
    def header(name)
      @env.response_headers[name]
    end
  end
end
