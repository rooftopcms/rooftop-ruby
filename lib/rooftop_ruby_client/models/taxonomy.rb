module RooftopRubyClient
  class Taxonomy
    include RooftopRubyClient::Base
    collection_path "taxonomies"
    primary_key "slug"
    has_many :terms, class_name: "RooftopRubyClient::TaxonomyTerm"
  end
end