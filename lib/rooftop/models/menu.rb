module Rooftop
  class Menu
    include Rooftop::Base
    has_many :menu_items, class: "Rooftop::MenuItem"
    collection_path "menus"
    coerce_field items: ->(items) { items.collect {|i| MenuItem.new(i)} unless items.nil?}
  end
end