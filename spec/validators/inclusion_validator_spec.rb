require 'spec_helper'
require 'support/shared_examples_for_validators'

shared_examples "it validates the inclusion of each member of the attribute value" do

  context "all attribute value members are valid" do
    before { record.field = ["foo", "bar"] }
    it "should be valid" do
      expect(record).to be_valid
    end
  end

  context "one of the attribute value members is invalid" do
    before { record.field = ["foo1", "bar"] }
    it "should be invalid" do
      expect(record).to be_invalid
    end
    it "should 'fix' the error message to include the value" do
      record.valid?
      expect(record.errors[:field]).to eq ["value \"foo1\" is not included in the list"]
    end
  end

end

describe Hydra::Validations::InclusionValidator do

  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end

  before(:each) { Validatable.clear_validators! }

  after(:all) { Object.send(:remove_const, :Validatable) }

  let(:valid_values) { ["foo", "bar", "baz"] }

  describe ".validates" do
    before { Validatable.validates :field, inclusion: { in: valid_values } }
    it_behaves_like "it validates the inclusion of each member of the attribute value" do
      let(:record) { Validatable.new }
    end
  end

  describe ".validates_inclusion_of" do
    before { Validatable.validates_inclusion_of :field, in: valid_values }
    it_behaves_like "it validates the inclusion of each member of the attribute value" do
      let(:record) { Validatable.new }
    end
  end

  it_behaves_like "an enumerable validator" do
    let(:options) { { inclusion: { in: valid_values } } }
    let(:record_class) { Validatable }
    let(:attribute) { :field }
  end

end
