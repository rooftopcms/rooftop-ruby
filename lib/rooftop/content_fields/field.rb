module Rooftop
  module Content
    class Field
      def initialize(args)
        puts "****"
        puts args.inspect
        args.each do |k,v|
          k = k.to_sym
          instance_variable_set("@#{k}", v)
          self.class.send(:attr_accessor, k)
        end
      end

      def parse_links
        puts " TODO: this is where we parse links"
      end
    end
  end
end