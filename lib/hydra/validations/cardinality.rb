require 'active_support/core_ext/array/wrap'

module Hydra
  module Validations
    #
    # CardinalityValidator - A cardinality validator for enumerable values based on
    # ActiveModel's LengthValidator.
    #
    # validates :field, cardinality: { minimum: 1, maximum: 5 }
    # validates :field, cardinality: { in: 1..5 }
    # validates :field, cardinality: { within: 1..5 }
    # validates :field, cardinality: { is: 1 }
    #
    # See ActiveModel::Validations::LengthValidator for options.
    #
    class CardinalityValidator < ActiveModel::Validations::LengthValidator

      def initialize(options = {})
        super(default_options.merge(options))
      end

      def validate_each(record, attribute, value)
        return if options[:allow_empty] && value.respond_to?(:empty?) && value.empty?
        super
      end

      protected

      def default_options
        { wrong_length: "has the wrong cardinality (should have %{count} value(s))", 
          too_short: "has too few values (minimum cardinality is %{count})", 
          too_long: "has too many values (maximum cardinality is %{count})"
        }
      end

      private 

      # Override
      def tokenize(value)
        Array.wrap(value)
      end

    end

    module HelperMethods
      def validates_cardinality_of *attr_names
        validates_with CardinalityValidator, _merge_attributes(attr_names)
      end

      def validates_single_cardinality_of *attr_names
        options = _merge_attributes(attr_names).merge(is: 1)
        validates_with CardinalityValidator, options
      end
    end

  end
end
