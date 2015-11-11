module Rooftop
  class ContentField
    def initialize(args)
      args.each do |k,v|
        instance_variable_set("@#{k}", v)
        self.class.send(:attr_accessor, k)
      end
    end
  end
end