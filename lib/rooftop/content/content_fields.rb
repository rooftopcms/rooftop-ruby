module Rooftop
  # The Rooftop API returns content for basic and advanced custom fields together. This module
  # cleans up the response, and creates a collection of ContentField objects, with which we can do
  # things like parse links.
  module Content
    def self.included(base)
      base.include Rooftop::HookCalls
      base.send(:add_to_hook, :after_find, ->(r) {
        # basic content is the stuff which comes from WP by default.
        if r.respond_to?(:content) && r.content.is_a?(Hash)
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
          schema = (Rooftop.configuration.advanced_options[:use_advanced_fields_schema] && r.respond_to?(:advanced_fields)) ? r.advanced_fields : nil
          r.fields = Rooftop::Content::Collection.new((basic_fields + advanced_fields), r, schema)
        end
      })

      base.send(:add_to_hook, :after_initialize, ->(r) {
        r.stub_fields! unless r.persisted?
        if r.class.respond_to?(:write_advanced_fields?) && r.class.write_advanced_fields? && Rooftop.configuration.advanced_options[:use_advanced_fields_schema]
          r.fields = Rooftop::Content::Collection.new({}, r, r.advanced_fields) unless r.persisted?
        end

      })

      base.send(:before_save, ->(r) {
        # if this object is allowed to write back to ACF, we need to build up the appropriate structure
        if r.respond_to?(:write_advanced_fields) && r.write_advanced_fields?
          r.content[:advanced] = r.fields.to_params
        end

        r.status_will_change!# unless r.persisted?
        r.slug_will_change!# unless r.persisted?
        r.content_will_change!
        r.restore_fields! # in any case, remove the fields attribute to nothing; we don't want to send this back.
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

    def stub_fields!

      unless respond_to?(:content) && content.is_a?(Hash)
        self.class.send(:attr_accessor, :content)
        self.class.send(:define_attribute_method, :content)
        self.content = {"basic"=>{"content"=>"", "excerpt"=>""}, "advanced"=>[]}.with_indifferent_access
      end
      unless respond_to?(:status)
        self.class.send(:attr_accessor, :status)
        self.class.send(:define_attribute_method, :status)
        self.status = 'draft'
      end
      unless respond_to?(:slug)
        self.class.send(:attr_accessor, :slug)
        self.class.send(:define_attribute_method, :slug)
      end
      unless respond_to?(:title)
        self.class.send(:attr_accessor, :slug)
        self.class.send(:define_attribute_method, :slug)
      end
    end
    
  end
end
