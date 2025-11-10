# frozen_string_literal: true

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    protected

    def current_user
      context[:current_user]
    end

    def require_authentication!
      raise Error::UnauthorizedError.new("Authentication required") unless current_user
    end
  end
end
