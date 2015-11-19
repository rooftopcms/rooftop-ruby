module Rooftop
  class Menu
    include Rooftop::Base
    has_many :menu_items, class: "Rooftop::MenuItem"
    self.api_namespace = "wp-api-menus"
    self.api_version = 2
    # coerce_field items: ->(items) { items.collect {|i| MenuItem.new(i)} unless items.nil?}
  end
end