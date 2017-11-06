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
              if field[:class].present?
                field[:type] = field[:class]
              end
              field.delete(:class)
            end
            fieldset[:fields]
          end
          advanced_fields.flatten!
          schema = Rooftop.configuration.advanced_options[:use_advanced_fields_schema] ? r.advanced_fields : nil
          r.fields = Rooftop::Content::Collection.new((basic_fields + advanced_fields), r, schema)
        end
      })

      base.send(:add_to_hook, :after_initialize, ->(r) {
        if r.class.write_advanced_fields && Rooftop.configuration.advanced_options[:use_advanced_fields_schema]
          r.fields = Rooftop::Content::Collection.new({}, r, r.advanced_fields)
        end
      })

      base.send(:before_save, ->(r) {
        r.restore_fields! unless r.new?
        #TODO we need to write these back into the actual fields.
      })
    end

    # test whether an instance has a field by name. Accepts a second argument if you want to test either the string value or the class.
    def has_field?(name, comparison=nil)
      has_field = fields.respond_to?(name.to_sym)
      if comparison.present? && comparison.is_a?(String)
        has_field && (fields.send(name.to_sym) == comparison)
      elsif comparison.present?
        has_field && fields.send(name.to_sym).is_a?(comparison)
      else
        has_field
      end
    end
  end
end
