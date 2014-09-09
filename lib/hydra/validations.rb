require "active_model"
require "hydra/validations/version"

module Hydra
  module Validations
    extend ActiveSupport::Concern

    included do
      extend HelperMethods
      include HelperMethods
    end

    module ClassMethods
      protected
      # Overwrites ActiveModel::Validations::ClassMethods, adding :allow_empty
      def _validates_default_keys
        [:if, :unless, :on, :allow_blank, :allow_nil, :strict, :allow_empty]
      end
    end

  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].each { |file| require file }
