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
    # - Attribute cannot be multi-valued (:multiple=>true option of `has_attributes')
    # - :solr_name option must be present
    #
    # CAVEAT: The determination of uniqueness depends on a Solr query.
    # False negatives (record invalid) may result if, for example,
    # querying a Solr field of type "text".
    #
    class UniquenessValidator < ActiveModel::EachValidator

      def initialize(options = {})
        super
        attributes.each do |attr|
          raise ArgumentError, "Cannot validate uniqueness on a multi-valued attribute: #{attribute}." if options[:class].multiple?(attr)
        end
      end

      def check_validity!
        raise ArgumentError, "UniquenessValidator accepts only a single attribute: #{attribues}" if attributes.length > 1 
        raise ArgumentError, "UniquenessValidator requires the :solr_name option be present." unless options[:solr_name].present?
      end

      def validate_each(record, attribute, value)
        conditions = {options[:solr_name] => value}
        conditions.merge!("-id" => record.id) if record.persisted?
        if record.class.exists? conditions
          record.errors.add attribute, "has already been taken" 
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
