module Rooftop
  module Page
    def self.included(base)
      base.include Rooftop::Base
      base.include Rooftop::Nested
      base.extend ClassMethods
    end

    module ClassMethods


    end



  end
end