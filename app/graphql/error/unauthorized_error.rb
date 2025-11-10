# frozen_string_literal: true

module Error
  class UnauthorizedError < BaseError
    def initialize(message = "Unauthorized")
      super(message, status: 401, code: "UNAUTHORIZED")
    end
  end
end
