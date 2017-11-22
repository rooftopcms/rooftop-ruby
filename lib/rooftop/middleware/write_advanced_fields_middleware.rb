# to _embed (as well as sending the original)

module Rooftop
  class WriteAdvancedFieldsMiddleware < Faraday::Middleware

    def call(env)
      # Some post types may allow writing to advanced fields. If this is the case, we need to set a header to tell Rooftop it's OK to write to them.
      if env.body && env.body.has_key?(:write_advanced_fields) && env.body[:write_advanced_fields]
        env[:request_headers]['acf-write-enabled'] = 'true'
        env.body.delete(:write_advanced_fields)
      end
      
      @app.call env
    end

  end

end


