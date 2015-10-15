module Rooftop
  class Taxonomy
    include Rooftop::Base
    collection_path "taxonomies"
    primary_key "slug"
    has_many :terms, class_name: "Rooftop::TaxonomyTerm"
  end
end