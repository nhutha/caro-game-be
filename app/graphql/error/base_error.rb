# frozen_string_literal: true

module Error
  class BaseError < GraphQL::ExecutionError
    attr_reader :status, :error_code, :resource, :field, :message

    def initialize(message = nil, status: 500, code: nil, options: {})
      super(message)
      @message = message
      @status = status
      @error_code = code || self.class.name.demodulize.underscore.upcase
      @resource = options[:resource]
      @filed = options[:field]
    end

    def to_h
      super.merge({resource: @resource}) if @resource
      super.merge({field: @field}) if @field
      super.merge({
        message: @message,
        code: @error_code,
        status: @status
      })
    end
  end
end
