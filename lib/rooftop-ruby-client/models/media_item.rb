module RooftopRubyClient
  class MediaItem
    include RooftopRubyClient::Base
    include RooftopRubyClient::AuthorCoercion
    collection_path "media"
  end
end