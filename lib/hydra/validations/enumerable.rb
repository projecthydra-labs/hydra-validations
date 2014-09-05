require 'forwardable'

module Hydra
  module Validations
    #
    # EnumerableValidator - Delegates validation of enumerable value members to another
    # ActiveModel::EachValidator instance.
    #
    # Behavior includes 'fixing' each error message to include the specific value
    # which was invalid.
    #
    # Adds a new option `allow_empty` to bypass validation of empty enumerable values.
    # One can also use the standard `allow_blank`, but `allow_empty` may be semantically
    # clearer.  Note that validation will *always* fail if the value is an empty enumerable and
    # `allow_empty` is false or nil (and `allow_blank` is not used).
    # 
    # See also ActiveModel::EachValidator#validate.
    #
    class EnumerableValidator < SimpleDelegator

      def initialize(member_validator)
        unless member_validator.is_a? ActiveModel::EachValidator
          raise ArgumentError, "Member validator must be an ActiveModel::EachValidator (or subclass)."
        end
        __setobj__(member_validator)
      end

      # Duplicates ActiveModel::EachValidator
      def validate(record)
        attributes.each do |attribute|
          value = record.read_attribute_for_validation(attribute)
          next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
          validate_each(record, attribute, value)
        end
      end

      def validate_each(record, attribute, value)
        return __getobj__.validate_each(record, attribute, value) unless value.respond_to?(:each)
        if value.respond_to?(:empty?) && value.empty? && !options[:allow_empty]
          return record.errors.add(attribute, "can't be empty")
        end
        value.each do |v| 
          previous_error_count = record.errors[attribute].size rescue 0
          __getobj__.validate_each(record, attribute, v)
          messages = record.errors[attribute]
          if messages && messages.size > previous_error_count
            record.errors.add(attribute, fixed_message(v, messages.pop))
          end
        end
      end

      protected

      def fixed_message(value, message)
        "value \"#{value}\" #{message}"
      end

    end
  end
end
