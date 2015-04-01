require 'hydra/validations/enumerable_behavior'
module Hydra
  module Validations
    class PresenceValidator < ActiveModel::Validations::PresenceValidator
      def validate_each(record, attribute, values)
        values = Array.wrap(values)
        record.errors.add(attribute, :blank, options) if values.blank? || values.any?(&:blank?)
      end
    end
    module HelperMethods
      def validates_presence_of *attr_names
        validates_with PresenceValidator, _merge_attributes(attr_names)
      end
    end
  end
end
