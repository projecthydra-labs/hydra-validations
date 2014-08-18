#
# SingleCardinalityValidator - validates that an enumerator value has size 0 or 1
#
#    validates :myattr, single_cardinality: true
#    validates_single_cardinality_of :myattr
#
# Blank and nil values are considered valid (even without :allow_blank or :allow_nil
# validator options).
#
module Hydra
  module Validations

    class SingleCardinalityValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if value.respond_to?(:each)
          record.errors.add(attribute, "can't have more than one value") if value.size > 1
        end
      end
    end

    module HelperMethods
      def validates_single_cardinality_of *attr_names
        validates_with SingleCardinalityValidator, _merge_attributes(attr_names)
      end
    end

  end
end

