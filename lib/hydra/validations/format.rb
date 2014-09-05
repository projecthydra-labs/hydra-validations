require 'hydra/validations/enumerable'

module Hydra
  module Validations
    #
    # FormatValidator - Validates attribute value format with support for enumerables.
    #
    # See ActiveModel::Validations::FormatValidator for usage and options.
    #
    class FormatValidator < EnumerableValidator

      def initialize(options = {})
        member_validator = ActiveModel::Validations::FormatValidator.new(options)
        super(member_validator)
      end

      module HelperMethods
        def validates_format_of *attr_names
          validates_with FormatValidator, _merge_attributes(attr_names)
        end
      end

    end
  end
end
