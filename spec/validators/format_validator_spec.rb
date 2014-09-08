require 'spec_helper'
require 'support/shared_examples_for_validators'

shared_examples "it validates the format of each member of the attribute value" do
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
      expect(record.errors[:field]).to eq ["value \"foo1\" is invalid"]
    end
  end
end

describe Hydra::Validations::FormatValidator do

  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end

  before(:each) { Validatable.clear_validators! }

  after(:all) { Object.send(:remove_const, :Validatable) }

  describe "class methods" do
    describe ".validates" do
      before { Validatable.validates :field, format: { with: /\A[[:alpha:]]+\Z/ } }
      it_behaves_like "it validates the format of each member of the attribute value" do
        let(:record) { Validatable.new }
      end
    end
  end
  describe "helper methods" do
    describe ".validates_format_of" do
      before { Validatable.validates_format_of :field, with: /\A[[:alpha:]]+\Z/ }
      it_behaves_like "it validates the format of each member of the attribute value" do
        let(:record) { Validatable.new }
      end
    end
  end

  it_behaves_like "an enumerable validator" do
    let(:options) { { format: { with: /\A[[:alpha:]]+\Z/ } } }
    let(:record_class) { Validatable }
    let(:attribute) { :field }
  end

end
