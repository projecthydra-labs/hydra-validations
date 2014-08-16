require "active_model"
require "hydra/validations/version"

module Hydra
  module Validations
    extend ActiveSupport::Concern

    included do
      extend HelperMethods
      include HelperMethods
    end

  end
end

Dir[File.dirname(__FILE__) + "/validations/*.rb"].each { |file| require file }
