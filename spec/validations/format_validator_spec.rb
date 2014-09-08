require 'spec_helper'

describe Hydra::Validations::FormatValidator do

  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
      validates :field, format: { with: /\A[[:alpha:]]+\Z/ }
    end
  end

  after(:all) { Object.send(:remove_const, :Validatable) }

  before(:each) { allow(record).to receive(:field) { value } }

  let(:record) { Validatable.new }

  describe "when the value is a scalar" do
    describe "which matches the format" do
      let(:value) { "foo" }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "which does not match the format" do
      let(:value) { "foo1" }
      it "should be invalid" do
        expect(record).to be_invalid
      end
      it "should have the standard error message" do
        record.valid?
        # TODO i18n
        expect(record.errors[:field]).to eq ["is invalid"]
      end
    end
  end

  describe "when the value is an enumerable" do
    describe "and all value members match the format" do
      let(:value) { ["foo", "bar"] }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and one value member does not match the format" do
      let(:value) { ["foo1", "bar"] }
      it "should be invalid" do
        expect(record).to be_invalid
      end
      it "should 'fix' the error message to include the value" do
        record.valid?
        # TODO i18n
        expect(record.errors[:field]).to eq ["value \"foo1\" is invalid"]
      end
    end
  end

end
