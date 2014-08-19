require 'hydra/validations/enumerable_behavior'

module Hydra
  module Validations
    #
    # FormatValidator - Add EnumerableBehavior to ActiveModel's FormatValidator
    #
    # See ActiveModel::Validations::FormatValidator for usage and options.
    #
    class FormatValidator < ActiveModel::Validations::FormatValidator
      include EnumerableBehavior
    end

    module HelperMethods
      def validates_format_of *attr_names
        validates_with FormatValidator, _merge_attributes(attr_names)
      end
    end

  end
end
