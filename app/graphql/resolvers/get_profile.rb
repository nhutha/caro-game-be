# frozen_string_literal: true

module Resolvers
  class GetProfile < BaseResolver
    type Types::UserType, null: true

    description "Get current user profile"

    def resolve
      require_authentication!

      current_user
    end
  end
end
