require 'hydra/validations/enumerable'

module Hydra
  module Validations
    #
    # InclusionValidator - Validates attribute value inclusion with support for enumerables.
    #
    # See ActiveModel::Validations::InclusionValidator for usage and options
    #
    class InclusionValidator < EnumerableValidator

      def initialize(options = {})
        member_validator = ActiveModel::Validations::InclusionValidator.new(options)
        super(member_validator)
      end

      module HelperMethods
        def validates_inclusion_of *attr_names
          validates_with InclusionValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end
