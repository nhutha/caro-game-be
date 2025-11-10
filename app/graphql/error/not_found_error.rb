# frozen_string_literal: true

module Error
  class NotFoundError < BaseError
    def initialize(message = "Record not found", resource: nil, field: nil)
      super(message, status: 404, code: "NOT_FOUND", resource: resource, field: field)
    end
  end
end
