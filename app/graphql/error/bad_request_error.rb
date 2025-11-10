# frozen_string_literal: true

module Error
  class BadRequestError < BaseError
    def initialize(message = "Bad request", resource: nil, field: nil)
      super(message, status: 400, code: "BAD_REQUEST", resource: resource, field: field)
    end
  end
end
