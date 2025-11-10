# frozen_string_literal: true

module Error
  class BaseError < GraphQL::ExecutionError
    attr_reader :status, :error_code, :resource, :field, :message, :errors

    def initialize(message = nil, status: 500, code: nil, options: {})
      super(message)
      @message = message
      @status = status
      @error_code = code || self.class.name.demodulize.underscore.upcase
      @resource = options[:resource]
      @field = options[:field]
      @errors = options[:errors]
    end

    def to_h
      error = {
        message: @message,
        code: @error_code,
        status: @status
      }
      error[:resource] = @resource if @resource
      error[:field] = @field if @field
      error[:errors] = @errors if @errors

      super.merge(error)
    end
  end
end
