# We use the WP-API v2 API, which is still in beta. At the moment, the filters aren't working
# so we mimic them on the Ruby side. Not ideal, but it gets things working.

# see https://github.com/WP-API/WP-API/issues/924 for more info
module RooftopClient
  module Queries
    module FindBy
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # find_by filters an array of objects to just the ones we want.
        # We assume that we AND the records together
        # @param args [Hash] as hash of field => search options
        # @return [Array] of selected records
        def find_by(args)
          all.to_a.select do |record|
            args.all? { |k,v| record.send(k) == v}
          end
        end
      end
    end
  end
end