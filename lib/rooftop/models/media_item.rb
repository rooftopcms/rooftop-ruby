module Rooftop
  class MediaItem
    include Rooftop::Base
    self.api_endpoint =  "media"

    attr_reader :new_file, :file
    define_attribute_method :file

    after_find ->(r) {
      r.caption = r.caption[:raw] if r.caption.is_a?(Hash)
    }

    def save
      attributes = {
        title: self.title,
        caption: self.caption
      }
      if file_changed?
        attributes.merge!({
                            file: Faraday::UploadIO.new(@file, @mime_type, @file_name),
                            _headers: {
                              'Content-Disposition' => @content_disposition,
                              'Content-Type' => 'multipart/form-data'
                            }
                          })
      end

      if persisted?
        if file_changed?
          response = self.class.put_raw(self.class.collection_path + "/#{self.id}", attributes)
          self.assign_attributes(response[:parsed_data][:data].with_indifferent_access)
          self.run_callbacks(:find)
          # self.changed_attributes.clear
          self
        else
          super

        end
      else
        response = self.class.post_raw(self.class.collection_path, attributes)
        self.assign_attributes(response[:parsed_data][:data].with_indifferent_access)
        self.run_callbacks(:find)
        # self.changed_attributes.clear
        self

      end

    end

    def file=(file)
      if persisted?
        raise NotImplementedError, "You can't replace a file at the moment. Delete and recreate."
      end


      if file.is_a?(String)
        @file = File.open(file, 'rb')
      else
        @file = file
      end
      
      @file_name ||= File.basename(@file.path)
      @mime_type ||= MIME::Types.type_for(File.extname(@file_name)).first
      @content_disposition ||= "attachment; filename=#{@file_name}"
      file_will_change!
    end

    def new_file=(new_file)
      self.file = new_file
      file_will_change!
    end

    def file_name=(name)
      @file_name = name
      @content_disposition = "attachment; filename=#{name}"
    end

    def stub_fields!
      
      unless respond_to?(:file_name)
        self.class.send(:attr_reader, :file_name)
        self.class.send(:define_attribute_method, :file_name)
        file_name_will_change!
      end

      unless respond_to?(:mime_type)
        self.class.send(:attr_accessor, :mime_type)
        self.class.send(:define_attribute_method, :mime_type)
        mime_type_will_change!
      end

      unless respond_to?(:content_disposition)
        self.class.send(:attr_accessor, :content_disposition)
        self.class.send(:define_attribute_method, :content_disposition)
        content_disposition_will_change!
      end
      unless respond_to?(:caption)
        self.class.send(:attr_accessor, :caption)
        self.class.send(:define_attribute_method, :caption)
        caption_will_change!
      end
      super
    end




  end
end