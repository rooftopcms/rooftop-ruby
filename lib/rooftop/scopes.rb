module Rooftop
  module Scopes
    def self.included(base)
      base.send(:scope, :with_embedded_resources, -> {where(include_embedded_resources: true)})
    end


  end
end