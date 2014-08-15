require "hydra/validations/version"

module Hydra
  module Validations
    extend ActiveSupport::Concern

    module ClassMethods
      def validates_single_cardinality_of *attr_names
        validates_with SingleCardinalityValidator, _merge_attributes(attr_names)
      end
    end

  end
end
