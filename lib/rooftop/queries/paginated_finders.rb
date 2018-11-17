module Rooftop
  module PaginatedFinders

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def where(args)
        super
      end

      alias_method :find_by, :where

      def find_by!(args)
        results = find_by(args)
        if results.present?
          results
        else
          raise Rooftop::RecordNotFoundError
        end
      end

      # 'all' needs to have a querystring param passed to really get all. It should be -1 but for some reason that's not working.
      def all(args = {})
        super({per_page: Rooftop::Queries::PER_PAGE}.merge(args))
      end
    end
  end
end