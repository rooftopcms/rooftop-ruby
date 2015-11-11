module Rooftop
  module ResourceLinks
    class Link
      attr_accessor :link_type
      def initialize(link_type,args)
        @link_type = link_type
        args.each do |k,v|
          instance_variable_set("@#{k}", v)
          self.class.send(:attr_accessor, k)
        end
      end

      def resolve
        raise NotImplementedError, "TODO: resolve the link."
      end
    end
  end
end
