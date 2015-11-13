module Rooftop
  module ResourceLinks
    class Link < ::OpenStruct
      attr_accessor :link_type
      def initialize(link_type,args)
        @link_type = link_type
        super(args)
      end

      def resolve
        raise NotImplementedError, "TODO: resolve the link."
      end
    end
  end
end
