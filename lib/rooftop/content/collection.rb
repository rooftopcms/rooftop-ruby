module Rooftop
  module Content
    class Collection < ::Array
      attr_reader :owner, :schema
      def initialize(content_fields, owner=nil, schema=nil)
        @owner = owner
        @schema = schema
        content_fields = content_fields.to_a
        # get the missing fields from the schema, so we can stub out all fields.
        # If there's no schema, missing fields is an empty array.
        missing_fields = (schema || {}).inject([]) do |array, schema_field|
          next array if content_fields.find {|f| f[:name] == schema_field[:name]}
          if schema_field[:type].in?(['repeater','relationship', 'taxonomy', 'user'])
            schema_field[:value] = []
          end
          array << schema_field
        end
        (content_fields + missing_fields).each do |field|
          # if the field has a 'fields' key, it is a repeater field. Collect the sub-fields and
          # set the field content to the collection of repeated fields
          if field.has_key?('fields')
            if @schema.is_a?(Array)
              nested_schema = @schema.find {|f| f[:name] == field['name'].to_s}[:fields] rescue nil
            else
              nested_schema = nil
            end
            if Rooftop.configuration.advanced_options[:create_nested_content_collections]
              repeated_fields = field[:fields].collect do |repeated_fields|
                collection = self.class.new(repeated_fields, self, nested_schema)
                # repeated_fields.each {|field| collection << Rooftop::Content::Field.new(field)}
                collection
              end
            else
              repeated_fields = field[:fields].collect do |repeated_fields|
                repeated_fields.collect{|field| Rooftop::Content::Field.new(field)}
              end
            end
            field.delete(:fields)
            field[:value] = repeated_fields
          end

          self << Rooftop::Content::Field.new(field)
        end

      end

      # When setting up a content collection, we pass in the owner of the collection.
      # If that's another collection, we're dealing with nested fields so we need to get the root owner
      def root_owner
        if @owner.is_a?(Collection)
          # we need to traverse up the owners 'til we get to the root owner
          @owner.root_owner
        else
          @owner
        end
      end

      # Find content_fields by attribute. Assume there will only be one attribute in the search
      def find_by(hash)
        raise ArgumentError, "you can only find a field by one attribute at a time" unless hash.length == 1
        attr = hash.first.first
        val = hash.first.last
        self.select {|l| l.send(attr) == val.to_s}
      end

      def named(name)
        find_by(name: name.to_s)
      end

      def field_names
        if (root_owner.present? && root_owner.persisted?) || @schema.nil?
          collect(&:name)
        else
          @schema.collect {|f| f[:name]}
        end
      end

      def owner_field
        if owner.is_a?(Collection)
          schema_field = owner.schema.find {|f| f[:fields] == schema}
          owner.named(schema_field[:name]).first
        end
      end

      alias_method :names, :field_names

      def respond_to_missing?(method, private=false)
        if schema.nil?
          # if there isn't a schema for this collection, we need to assume that we should only call
          # method_missing for methods where this is a corresponding field name
          if named(method).length > 0
            true
          else
            super
          end
        else
          #If there's a schema for this collection, we need to support fields which don't exist, but could.
          if schema_includes_field?(method)
            true
          else
            super
          end
        end
      end

      def method_missing(method, *args, &block)
        if Rooftop.configuration.advanced_options[:use_advanced_fields_schema]
          if root_owner.class.respond_to?(:write_advanced_fields?) && root_owner.class.write_advanced_fields? && method.to_s =~ /=$/ && schema_includes_field?(method)
            set_value(method, args)
          elsif method.to_s =~ /=$/
            raise Rooftop::AdvancedFields::NotWriteableError, "Advanced fields aren't writeable on #{self.root_owner.class} or field doesn't exist"
          else
            get_value(method, args)
          end
        else
          get_value(method, args)
        end

      end

      def <<(thing)
        # TODO - we need to support checking whether the field already exists and overwrite it.
        super
      end

      def to_params
        if owner == root_owner
          # this is a top-level collection, owned by the object. We need to build up the whole object
          changed_fields = self.collect do |field|
            if field.changed? || field.type == 'repeater'
              field.to_param
            else
              next
            end
          end

          changed_fields.compact.each_with_index.inject({}) do |hash, (field, index)|
            hash[index] = {
              fields: {
                0 => field
              }
            }
            hash
          end

        else
          # this is a nested content collection, so we just need to iterate over our own fields
          changed_fields = self.collect do |field|
            if field.changed? || field.type == "repeater" || owner_field.try(:type) == 'repeater'
              field.to_param
            else
              next
            end
          end
          changed_fields.compact.each_with_index.inject({}) do |hash, (field, index)|
            hash[index] = field
            hash
          end
        end
      end

      private

      def get_value(method, args)
        fields = named(method)
        use_raw = args.first.is_a?(Hash) && args.first.has_key?(:raw) && args.first[:raw]
        if fields.length > 0
          if Rooftop.configuration.advanced_options[:resolve_relations]
            use_raw ? fields.first : fields.first.resolve
          else
            use_raw ? fields.first : fields.first.value
          end
        else
          raise Rooftop::Content::FieldNotFoundError, "No field named #{method} was found"
        end
      end

      def set_value(method, args)
        field_name = method.to_s.gsub("=","")
        fields = named(field_name)
        if fields.length > 0
          fields.first.value = args.first
        else
          raise Rooftop::Content::FieldNotFoundError, "No field named #{method} was found"
        end
      end

      def schema_includes_field?(method)
        method = method.to_s
        field = @schema.find {|field| field[:name] == method || field[:name] == method.gsub('=','')}
        !field.nil? || named(method).length > 0
      end

    end
  end
end
