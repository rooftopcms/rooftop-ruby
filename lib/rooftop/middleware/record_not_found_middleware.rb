module Rooftop
  class RecordNotFoundMiddleware < Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
        when 404
          raise Rooftop::RecordNotFoundError, '404 received from Rooftop API'
      end
    end
  end

end