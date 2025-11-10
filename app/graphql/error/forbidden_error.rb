# frozen_string_literal: true

module Error
  class ForbiddenError < BaseError
    def initialize(message = "Forbidden", resource: nil, field: nil)
      super(message, status: 403, code: "FORBIDDEN", resource: resource, field: field)
    end
  end
end
