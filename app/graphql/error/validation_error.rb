# frozen_string_literal: true

module Error
  class ValidationError < BaseError
    def initialize(message = "Validation failed", record)
      full_messages = record.errors.to_hash full_message
      errors = record.errors.details.map do |field, details|
        detail = details.first
        detail_message = full_messages[field].first

       format_error(record, field, detail, detail_message)
      end.flatten

      super(message, status: 422, code: "VALIDATION_ERROR", options: { errors: errors })
    end

    private
    attr_reader :record, :detail_message, :detail

    def format_error(record, field, detail, detail_message)
      @record = record
      @detail_message = detail_message
      @detail = detail
      @field = field

      return error_for_nested_attributes if error_for_nested_attributes

      {
        resource:,
        field:,
        message: detail_message,
        **detail
      }
    end

    def resource
      I18n.t underscored_resource_name,
            scope: [ :errors, :resources ],
            default: underscored_resource_name
    end

    def field
      I18n.t @field,
            scope: [ :errors, :fields, underscored_resource_name ],
            default: @field.to_s
    end

    def error_for_nested_attributes
      return unless match = field.match(Settings.regex.validate_nested_attributes)

      {
        resource: match[1].split(".").last,
        field: match[3] || match[4],
        index: match[2] ? match[2].to_i : match[2],
        message:,
        **detail
      }
    end

    def underscored_resource_name
      record.class.to_s.gsub("::", "").underscore
    end
  end
end
