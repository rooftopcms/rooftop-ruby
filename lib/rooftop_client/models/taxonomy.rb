module RooftopClient
  class Taxonomy
    include RooftopClient::Base
    collection_path "taxonomies"
    primary_key "slug"
    has_many :terms, class_name: "RooftopClient::TaxonomyTerm"
  end
end