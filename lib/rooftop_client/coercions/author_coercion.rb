module RooftopClient
  module AuthorCoercion
    def self.included(base)
      base.send(:after_find, ->(r) { r.author.registered = DateTime.parse(r.author.registered)})
      base.send(:coerce_field, {author: ->(author) { RooftopClient::Author.new(author) }})
    end
  end
end
