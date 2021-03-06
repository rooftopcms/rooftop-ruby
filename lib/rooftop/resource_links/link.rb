module Rooftop
  module ResourceLinks
    class Link < ::OpenStruct
      attr_accessor :link_type

      def initialize(link_type,args, klass=nil)
        @link_type = link_type
        @mapped_class = klass.try(:resource_link_mapping).try(:[],@link_type)
        @klass = klass

        super(args)
      end

      def marshal_dump
        [@link_type, @table, @klass]
      end

      def marshal_load(array)
        @link_type = array[0]
        @table = array[1]
        @klass = array[2]
      end

      def resolve(klass=nil)
        # We need to figure out what we're going to instantiate. If it's in the resource link mapping, use that. If not, try the klass passed into the resolve() method. Failing that, make an attempt to constantize something; otherwise we're going to have to raise
        @mapped_class ||= klass || @link_type.camelize.classify.constantize
        if @mapped_class
          # If this link has an ID, we can call find() on the class
          if respond_to?(:id)
            return @mapped_class.send(:find, id)
          else
            # TODO this is a fudge to get around some hrefs which don't have /wp/v2 in them
            unless href =~ /wp\/v2/
              href.gsub!('wp-json','wp-json/wp/v2')
            end
            # otherwise we're going to have make a call to the link's href.
            result = @mapped_class.get(href)
            result.run_callbacks(:find)
            return result
          end
        else
          raise Rooftop::ResourceLinks::UnresolvableLinkError, "Couldn't resolve a link of type #{@link_type}. Try passing the class you want to resolve to."
        end

      end
    end
  end
end
