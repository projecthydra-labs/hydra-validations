require 'hydra/validations/cardinality'

module Hydra
  module Validations
    #
    # SingleCardinalityValidator - validates that an enumerator value has size 0 or 1
    #
    #    validates :myattr, single_cardinality: true
    #    validates_single_cardinality_of :myattr
    #
    # Blank and nil values are considered valid (even without :allow_blank or :allow_nil
    # validator options).
    #
    class SingleCardinalityValidator < ActiveModel::EachValidator
      
      include Cardinality

      def validate_each(record, attribute, value)
        validate_cardinality(:single, record, attribute, value)
      end

    end

    module HelperMethods
      def validates_single_cardinality_of *attr_names
        validates_with SingleCardinalityValidator, _merge_attributes(attr_names)
      end
    end

  end
end

