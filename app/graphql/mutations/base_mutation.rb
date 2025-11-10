# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    protected

    def current_user
      context[:current_user]
    end

    def require_authentication!
      raise Error::UnauthorizedError.new("Authentication required") unless current_user
    end

    def authorize!(condition, message = "Forbidden")
      raise Error::ForbiddenError.new(message) unless condition
    end

    def validation_error!(message, details = nil)
      raise Error::ValidationError.new(message, details: details)
    end

    def not_found!(message = "Record not found")
      raise Error::NotFoundError.new(message)
    end
  end
end
