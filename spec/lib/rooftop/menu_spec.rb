require 'spec_helper'

class Menu < Rooftop::Menu
    has_many :menu_items, class: "Rooftop::MenuItem"
    self.api_namespace = "wp-api-menus"
    self.api_version = 2
end

describe Menu do
    context "Fetching menus" do
        subject(:menu) {Menu.first}

        it "should return a menu object" do
            expect(menu.is_a?(Rooftop::Menu)).to equal(true)
        end

        it "should coerce items" do
            expect(menu.items.first.is_a?(Rooftop::MenuItem)).to equal(true)
        end
    end
end
