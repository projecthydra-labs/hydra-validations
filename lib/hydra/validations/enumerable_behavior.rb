module Hydra
  module Validations
    #
    # EnumerableBehavior - a mixin for subclasses of ActiveModel::EachValidator 
    # adding validation for each member of an enumerable attribute value.
    #
    # Behavior includes 'fixing' each error message to include the specific value
    # which was invalid.
    #
    # The `allow_empty` option can be used instead of `allow_blank` for greater
    # clarity and precision with enumerable values. If a validator includes
    # this mixin, an empty enumerable value will *always* be invalid unless
    # `allow_empty` is true.
    #
    # Note that `allow_nil` and `allow_blank` options apply to the enumerable
    # value, not to its members. Thus, for example, `allow_blank: true` will
    # not bypass validation of the value `[""]` even though its member `""` 
    # is blank.
    #
    module EnumerableBehavior

      def validate_each(record, attribute, value)
        return super unless value.respond_to?(:each)
        if value.respond_to?(:empty?) && value.empty?
          record.errors.add(attribute, "can't be empty") unless options[:allow_empty]
        else
          value.each do |v| 
            prev = record.errors[attribute].size rescue 0
            super(record, attribute, v)
            messages = record.errors[attribute]
            if messages && messages.size > prev
              record.errors.add(attribute, fixed_message(v, messages.pop))
            end
          end
        end
      end

      protected

      def fixed_message(value, message)
        "value \"#{value}\" #{message}"
      end

    end
  end
end
