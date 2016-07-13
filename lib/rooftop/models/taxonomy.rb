module Rooftop
  class Taxonomy
    include Rooftop::Base
    self.api_version = 2
    self.api_namespace = "wp"
    self.api_endpoint = "taxonomies"

    primary_key "slug"

    def self.all
      taxonomies = []
      get_raw(self.collection_path) do |parsed, raw|
        parsed[:data].each do |tax,data|
          taxonomies << Taxonomy.new(data)
        end
      end
      taxonomies.each do |t|
        t.run_callbacks(:find)
      end
      return taxonomies
    end

    def terms
      TaxonomyTerm.get(resource_links.find_by(link_type: :item).first.href)
    end
  end
end
