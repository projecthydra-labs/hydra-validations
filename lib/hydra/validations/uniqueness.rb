require 'active_support/core_ext/array/wrap'

module Hydra
  module Validations
    #
    # UniquenessValidator - an ActiveFedora model validator
    #
    # Usage:
    #
    #   validates :field, uniqueness: { solr_name: "field_ssim" }
    #   validates_uniqueness_of :field, solr_name: "field_ssim"
    #
    # Restrictions:
    #
    # - Accepts only one attribute (can have more than one UniquenessValidator on a model, however)
    # - :solr_name option must be present
    # - Can be used on enumerable values (attribute defined with :multiple=>true option), but 
    #   validator also validates single cardinality, so will not pass validation if enumerable
    #   has more than one member.
    #
    # CAVEAT: The determination of uniqueness depends on a Solr query.
    # False negatives (record invalid) may result if, for example,
    # querying a Solr field of type "text".
    #
    class UniquenessValidator < ActiveModel::EachValidator

      def check_validity!
        if attributes.length > 1 
          raise ArgumentError, "UniquenessValidator accepts only a single attribute: #{attributes}" 
        end
        unless options[:solr_name].present?
          raise ArgumentError, "UniquenessValidator requires the :solr_name option be present." 
        end
      end

      def validate_each(record, attribute, value)
        wrapped_value = Array.wrap(value)
        if wrapped_value.length > 1
          record.errors.add(attribute, "can't have more than one value") 
        elsif wrapped_value.empty? 
          record.errors.add(attribute, "can't be empty") unless options[:allow_empty]
        else
          conditions = {options[:solr_name] => wrapped_value.first}
          conditions.merge!("-id" => record.id) if record.persisted?
          record.errors.add attribute, "has already been taken" if record.class.exists?(conditions)
        end
      end

    end

    module HelperMethods
      def validates_uniqueness_of *attr_names
        validates_with UniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
