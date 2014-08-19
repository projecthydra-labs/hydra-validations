module Hydra
  module Validations
    #
    # EnumerableBehavior - a mixin for subclasses of ActiveModel::EachValidator 
    # adding validation for each member of an enumerable attribute value.
    #
    # Behavior includes 'fixing' each error message to include the specific value
    # which was invalid.
    #
    module EnumerableBehavior

      def validate_each(record, attribute, value)
        if value.respond_to?(:each)
          value.each do |v| 
            prev = record.errors[attribute].size rescue 0
            super(record, attribute, v)
            messages = record.errors[attribute]
            if messages && messages.size > prev
              record.errors.add(attribute, fixed_message(v, messages.pop))
            end
          end
        else
          super
        end
      end

      protected

      def fixed_message(value, message)
        "value \"#{value}\" #{message}"
      end

    end
  end
end
