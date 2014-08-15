require 'spec_helper'
require 'single_cardinality_validator'

shared_examples "it validates the single cardinality of the field" do
  it "should be valid when the field value is nil" do
    subject.field = nil
    expect(subject).to be_valid
  end
  it "should be valid when the field value is a scalar" do
    subject.field = "foo"
    expect(subject).to be_valid
  end
  context "when the field value is an enumerable" do
    it "should be valid if the value is empty" do
      subject.field = []
      expect(subject).to be_valid
    end
    it "should be valid if the value has one element" do
      subject.field = ["foo"]
      expect(subject).to be_valid
    end
    it "should be invalid if the value has more than one element" do
      subject.field = ["foo", "bar"]
      expect(subject).not_to be_valid      
    end
  end
end

describe SingleCardinalityValidator do
  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end
  before(:each) { Validatable.clear_validators! }
  subject { Validatable.new }
  describe ".validates" do
    before { Validatable.validates :field, single_cardinality: true }
    it_behaves_like "it validates the single cardinality of the field"
  end
  describe ".validates_single_cardinality_of" do
    before { Validatable.validates_single_cardinality_of :field }
    it_behaves_like "it validates the single cardinality of the field"
  end
end
