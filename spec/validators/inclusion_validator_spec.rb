require 'spec_helper'

shared_examples "it validates the inclusion of each member of the attribute value" do
  context "all attribute value members are valid" do
    before { subject.field = ["foo", "bar"] }
    it "should be valid" do
      expect(subject).to be_valid
    end
  end
  context "one of the attribute value members is invalid" do
    before { subject.field = ["foo1", "bar"] }
    it "should be invalid" do
      expect(subject).to be_invalid
    end
    it "should 'fix' the error message to include the value" do
      subject.valid?
      expect(subject.errors[:field]).to eq ["value \"foo1\" is not included in the list"]
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
  subject { Validatable.new }
  let(:valid_values) { ["foo", "bar", "baz"] }
  describe ".validates" do
    before do
      Validatable.clear_validators!
      Validatable.validates :field, inclusion: { in: valid_values } 
    end
    it_behaves_like "it validates the inclusion of each member of the attribute value"
  end
  describe ".validates_inclusion_of" do
    before do
      Validatable.clear_validators!
      Validatable.validates_inclusion_of :field, in: valid_values 
    end
    it_behaves_like "it validates the inclusion of each member of the attribute value"
  end
end
