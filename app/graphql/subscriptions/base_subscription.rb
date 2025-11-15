module Subscriptions
  class BaseSubscription < GraphQL::Schema::Subscription
    def current_user
      context[:current_user]
    end

    def require_authentication!
      raise Error::UnauthorizedError.new("Authentication required") unless current_user
    end
  end
end
