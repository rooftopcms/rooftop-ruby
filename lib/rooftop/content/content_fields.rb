module Rooftop
  # The Rooftop API returns content for basic and advanced custom fields together. This module
  # cleans up the response, and creates a collection of ContentField objects, with which we can do
  # things like parse links.
  module Content
    def self.included(base)
      base.include Rooftop::HookCalls
      base.send(:add_to_hook, :after_find, ->(r) {
        # basic content is the stuff which comes from WP by default.
        if r.respond_to?(:content)
          basic_fields = r.content[:basic].collect {|k,v| {name: k, value: v, fieldset: "Basic"}}
          # advanced fields from from ACF, and are exposed in the api in this form:
          # [
          #   {
          #     "title"=>"The fieldset title",
          #     "fields"=>[
          #       {"name"=>"field name", "label"=>"display name", "class"=>"type of field", "value"=>"The value of the field"},
          #       {"name"=>"field name", "label"=>"display name", "class"=>"type of field",
          #        "value"=>"The value of the field"},
          #       etc.
          #     ]
          #   }
          # ]
          # Given that's a bit convoluted, we get both the content types into the same output format, like this:
          # {"field name", "label"=>"display name", "class"=>"type of field", "value"=>"value of the field", "fieldset"=>"fieldset if there is one, or Basic for the builtin ones"}
          advanced_fields = r.content[:advanced].collect do |fieldset|
            fieldset[:fields].each do |field|
              field.merge!(fieldset: fieldset[:title])
              field[:type] = field[:class]
              field.delete(:class)
            end
            fieldset[:fields]
          end.flatten
          r.fields = Rooftop::Content::Collection.new((basic_fields + advanced_fields))
        end
      })

      base.send(:before_save, ->(r) {
        r.restore_fields! unless r.new?
        #TODO we need to write these back into the actual fields.
      })
    end
  end
end