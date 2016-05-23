module Rooftop
  module Preview
    def preview
      preview_path = "#{self.class.collection_path}/#{self.id}/preview"
      @preview ||= self.class.get(preview_path)
      # if there's no preview, return nil
      if @preview.attributes.has_key?(:data) && @preview.data[:status] == 404
        return nil
      else
        return @preview
      end
    end

    def preview_key_matches?(key)
      preview.present? && preview.preview_key == key
    end

  end
end