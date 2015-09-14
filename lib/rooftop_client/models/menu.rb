module RooftopClient
  class Menu
    include RooftopClient::Base
    has_many :menu_items, class: "RooftopClient::MenuItem"
    collection_path "menus"
    coerce_field items: ->(items) { items.collect {|i| MenuItem.new(i)} unless items.nil?}
  end
end