module RooftopClient
  class MediaItem
    include RooftopClient::Base
    include RooftopClient::AuthorCoercion
    collection_path "media"
  end
end