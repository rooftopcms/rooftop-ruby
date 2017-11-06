module Rooftop
  module Page
    def self.included(base)
      @page_classes ||= []
      @page_classes << base unless @page_classes.include?(base)
      base.include Rooftop::Base
      base.include Rooftop::Nested
      base.include Rooftop::Preview
      base.include Rooftop::AdvancedFields::Schema
      base.include Rooftop::AdvancedFields::Writeable
      base.extend ClassMethods
    end

    def self.page_classes
      @page_classes
    end

    module ClassMethods


    end



  end
end