require 'hydra/validations/enumerable_behavior'

module Hydra
  module Validations
    #
    # InclusionValidation - Adds EnumerableBehavior to ActiveModel's InclusionValidator
    #
    # See ActiveModel::Validations::InclusionValidator for usage and options
    #
    class InclusionValidator < ActiveModel::Validations::InclusionValidator
      include EnumerableBehavior
    end

    module HelperMethods
      def validates_inclusion_of *attr_names
        validates_with InclusionValidator, _merge_attributes(attr_names)
      end
    end

  end
end
