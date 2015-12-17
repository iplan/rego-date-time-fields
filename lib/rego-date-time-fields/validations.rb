require 'active_model/validator'
require 'active_support/concern'

module DateTimeFields
  module ActiveModel
    module Validations
      extend ActiveSupport::Concern

      included do
        extend HelperMethods
        include HelperMethods
      end

      class TimeFormatValidator < ::ActiveModel::EachValidator

        def initialize(options)
          super(options.reverse_merge(:allow_blank=>false, :format => '%H:%M'))
        end

        def validate_each(record, attr_name, value)
          before_type_cast = "#{attr_name}_before_type_cast"

          raw_value = record.send("#{attr_name}_before_type_cast") if record.respond_to?(before_type_cast.to_sym)
          raw_value ||= value

          return if options[:allow_blank] && raw_value.blank?

          casted_value = DateTimeFields::TypeCaster.string_to_time(raw_value, options[:format])

          if casted_value.blank?
            record.errors.add(attr_name, :invalid, :format=>options[:format], :value=>raw_value)
          end
        end
      end

      module HelperMethods
        # Validates that the specified attributes are in strings in time format (as defined by :format option). Happens by default on save.
        #
        #   class Person < ActiveRecord::Base
        #     validates_time_format_of :nap_time
        #   end
        #
        # The event_time attribute must be in the object and it must be string in :format.
        #
        # Configuration options:
        # * <tt>:message</tt> - A custom error message (default is: "not in allowed time format").
        # * <tt>:format</tt> - strftime time format which will be accepted
        #
        # There is also a list of default options supported by every validator:
        # +:if+, +:unless+, +:on+ and +:strict+.
        # See <tt>ActiveModel::Validation#validates</tt> for more information
        def validates_time_format_of(*attr_names)
          validates_with TimeFormatValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end