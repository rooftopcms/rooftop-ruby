module Rooftop
  module Menus
    class Menu
      include Rooftop::Base
      self.api_namespace = "wp-api-menus"
      self.api_version = 2
      coerce_field items: ->(items) { items.collect {|i| Item.new(i)} unless items.nil?}
    end
  end
end