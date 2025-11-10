# frozen_string_literal: true

module Error
  class InternalServerError < BaseError
    def initialize(message = "Internal server error", resource: nil, field: nil)
      super(message, status: 500, code: "INTERNAL_SERVER_ERROR", resource: resource, field: field)
    end
  end
end
