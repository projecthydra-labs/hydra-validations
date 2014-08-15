require "hydra/validations/version"
require "hydra/validations/helper_methods"

module Hydra
  module Validations
    extend ActiveSupport::Concern

    included do
      include HelperMethods
    end

  end
end

Dir[File.dirname(__FILE__) + "/validations/*validator.rb"].each { |file| require file }
