module Rooftop
  module ResourceLinks
    class Link < ::OpenStruct
      attr_accessor :link_type
      def initialize(link_type,args)
        @link_type = link_type
        super(args)
      end

      def resolve(klass=nil)
        begin
          klass ||= @link_type.camelize.classify.constantize
          klass.get(@href)
        rescue
          raise Rooftop::ResourceLinks::UnresolvableLinkError, "Couldn't resolve a link of type #{@link_type}. You could try passing a class into the resolve() method."
        end

      end
    end
  end
end
