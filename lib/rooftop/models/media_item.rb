module Rooftop
  class MediaItem
    include Rooftop::Base
    self.api_endpoint =  "media"
    after_find do |record|
      record.fields << Rooftop::Content::Field.new({fieldset: "Basic", name: 'source_url', value: record.source_url})
      record.fields << Rooftop::Content::Field.new({fieldset: "Basic", name: 'caption', value: record.caption[:rendered]})
    end
  end
end