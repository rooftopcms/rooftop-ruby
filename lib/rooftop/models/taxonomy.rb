module Rooftop
  class Taxonomy
    include Rooftop::Base
    self.api_version = 2
    collection_path "taxonomies"
    primary_key "slug"
    has_many :terms, class_name: "Rooftop::TaxonomyTerm"
  end
end
