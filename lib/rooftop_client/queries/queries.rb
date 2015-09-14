module RooftopClient
  module Queries
    def self.included(base)
      base.include RooftopClient::Queries::FindBy
    end
  end
end