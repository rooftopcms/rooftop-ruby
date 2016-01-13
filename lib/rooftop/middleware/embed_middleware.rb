# This is a bit hacky. It looks like Her.rb strips querystrings with an underscore, and WP requires
# '?_embed' in order to embed child links. We look for a query param called 'embed' and change it
# to _embed (as well as sending the original)

module Rooftop
  class EmbedMiddleware < Faraday::Middleware

    def call(env)
      query = Faraday::Utils.parse_query(env.url.query) || {}
      query["_embed"] = true if query.has_key?("include_embedded_resources")
      env.url.query = Faraday::Utils.build_query(query.except("include_embedded_resources"))
      @app.call env
    end

  end

end