module Hydra
  module Validations
    module HelperMethods

      def validates_single_cardinality_of(*attr_names)
        validates_with SingleCardinalityValidator, _merge_attributes(attr_names)
      end

    end
  end
end
