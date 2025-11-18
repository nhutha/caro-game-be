# frozen_string_literal: true

module Error
  class NotFoundError < BaseError
    def initialize(message = "Record not found", error)
      super(message, status: 404, code: "NOT_FOUND", options: { resource:  error.model.underscore })
    end
  end
end
