# Rooftop::Queries is mixed into Her::Model::Relation, which is responsible for fetching the data to pass to the api. We redefine `fetch()` with our mutated parameters

module Rooftop
  module Queries
    PER_PAGE = 99999999
    def self.included(base)
      base.extend ClassMethods
    end

    def fetch
      if @parent.ancestors.include?(Rooftop::Base)
        @params = mutate_params(@params)
      end

      super
    end

    # We need to fix up the `where()` filter. WP-API expects a url format for filters like this:
    # /?filter[something]=foo. But we have a magic hash key to allow us to send things which aren't mangled.
    def mutate_params(args)
      args = HashWithIndifferentAccess.new(args)
      # the fact that 'slug' is referred to in the db as 'name' is irritating. Let's fix that
      # in queries so we can specify {slug: "foo"}
      if args.keys.collect(&:to_sym).include?(:slug)
        if args[:slug].is_a?(Array)
          args[:post_name__in] ||= []
          args[:slug].each do |slug|
            args[:post_name__in] << slug
          end
        else
          args[:name] = args[:slug]
        end
        args.delete(:slug)
      end

      if args.keys.collect(&:to_sym).include?(:id)
        if args[:id].is_a?(Array)
          args[:post__in] ||= []
          args[:id].each do |id|
            args[:post__in] << id
          end
        else
          args[:page_id] = args[:id]
        end
        args.delete(:id)
      end

      if args.keys.include?('per_page')
        per_page = args['per_page']
        args[:no_filter] ||= []
        args[:no_filter] << :per_page unless args[:no_filter].include?('per_page')
      else
        per_page = Rooftop::Queries::PER_PAGE
      end

      if args.keys.collect(&:to_sym).include?(:no_filter)
        args_to_filter = args.except(*args[:no_filter]).except(:no_filter)
        args_not_to_filter = args.except(args_to_filter).except(:no_filter)
        filters =  args_to_filter.inject({}) {|hash,pair| hash["filter[#{pair.first}]"] = pair.last; hash}
        filters = {per_page: per_page}.merge(filters).merge(args_not_to_filter)
      else
        #TODO DRY
        filters =  args.inject({}) {|hash,pair| hash["filter[#{pair.first}]"] = pair.last; hash}
        filters = {per_page: per_page}.merge(filters)
      end

      return filters
    end


  end
end
