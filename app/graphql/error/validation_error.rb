# frozen_string_literal: true

module Error
  class ValidationError < BaseError
    def initialize(message = "Validation failed", resource: nil, field: nil)
      super(message, status: 422, code: "VALIDATION_ERROR", resource: resource, field: field)
    end
  end
end
