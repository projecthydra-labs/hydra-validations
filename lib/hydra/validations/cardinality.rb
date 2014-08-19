module Hydra
  module Validations
    #
    # Cardinality - a mixin adding cardinality validation methods.
    #
    module Cardinality

      def validate_cardinality(cardinality, record, attribute, value)
        return validate_single_cardinality(record, attribute, value) if cardinality == :single
        raise ArgumentError, "Cardinality validation not supported: #{cardinality.inspect}"
      end

      def validate_single_cardinality(record, attribute, value)
        # TODO i18n message
        record.errors.add(attribute, "can't have more than one value") if value.respond_to?(:each) && value.size > 1
      end

    end
  end
end
