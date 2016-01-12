module Rooftop
  module Content
    class Collection < ::Array
      def initialize(content_fields)
        content_fields.each do |field|
          # if the field has a 'fields' key, it is a repeater field. Collect the sub-fields and
          # set the field content to the collection of repeated fields
          if field.has_key?('fields')
            repeated_fields = field[:fields].collect{|repeated_fields| repeated_fields.collect{|field| Rooftop::Content::Field.new(field)}}.flatten
            field.delete(:fields)
            field[:value] = repeated_fields
          end

          self << Rooftop::Content::Field.new(field)
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

      def method_missing(method, *args, &block)
        fields = named(method)
        if fields.length > 0
          fields.first.value
        else
          raise Rooftop::Content::FieldNotFoundError, "No field named #{method} was found"
        end
      end

      def respond_to_missing?(method, private=false)
        if named(method).length == 0
          super
        else
          true
        end
      end

    end
  end
end
