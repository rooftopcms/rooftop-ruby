module Rooftop
  module Content
    class Collection < ::Array
      attr_reader :owner, :schema
      def initialize(content_fields, owner=nil, schema=nil)
        @owner = owner
        @schema = schema
        content_fields.each do |field|
          # if the field has a 'fields' key, it is a repeater field. Collect the sub-fields and
          # set the field content to the collection of repeated fields
          if field.has_key?('fields')
            if Rooftop.configuration.advanced_options[:create_nested_content_collections]
              if @schema.is_a?(Array)
                nested_schema = @schema.find {|f| f[:name] == field['name'].to_s}[:fields] rescue nil
              end
              repeated_fields = field[:fields].collect do |repeated_fields|
                collection = self.class.new({}, self, nested_schema)
                repeated_fields.each {|field| collection << Rooftop::Content::Field.new(field)}
                collection
              end

              field.delete(:fields)
              field[:value] = repeated_fields
            else
              repeated_fields = field[:fields].collect do |repeated_fields|
                repeated_fields.collect{|field| Rooftop::Content::Field.new(field)}
              end

              field.delete(:fields)
              field[:value] = repeated_fields
            end
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
        collect(&:name)
      end

      alias_method :names, :field_names

      def method_missing(method, *args, &block)
        if method.to_s =~ /=$/
          set_value(method, args, block)
        #   set up the write
        else
          get_value(method, args, block)
        end

      end

      def respond_to_missing?(method, private=false)
        # TODO interrogate the schema to determine whether we should be able to write

        if named(method).length == 0
          super
        else
          true
        end
      end

      private

      def get_value(method, *args, &block)
        fields = named(method)
        if fields.length > 0
          if Rooftop.configuration.advanced_options[:resolve_relations]
            fields.first.resolve
          else
            fields.first.value
          end
        else
          raise Rooftop::Content::FieldNotFoundError, "No field named #{method} was found"
        end
      end

      def set_value(method, *args, &block)

      end


    end
  end
end
