require 'spec_helper'
require 'support/shared_examples_for_validators'

shared_examples "it validates the single cardinality of the attribute" do
  it_behaves_like "it validates the single cardinality of a scalar attribute"
  it_behaves_like "it validates the single cardinality of an enumerable attribute"
end

describe Hydra::Validations::SingleCardinalityValidator do
  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end
  before(:each) { Validatable.clear_validators! }
  after(:all) { Object.send(:remove_const, :Validatable) }
  subject { Validatable.new }
  describe ".validates" do
    before { Validatable.validates :field, single_cardinality: true }
    it_behaves_like "it validates the single cardinality of the attribute" do
      let(:attribute) { :field }
    end
  end
  describe ".validates_single_cardinality_of" do
    before { Validatable.validates_single_cardinality_of :field }
    it_behaves_like "it validates the single cardinality of the attribute" do
      let(:attribute) { :field }
    end
  end
end

