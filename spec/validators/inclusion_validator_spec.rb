require 'spec_helper'
require "support/shared_examples_for_enumerable_validators"

describe Hydra::Validations::InclusionValidator do

  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end

  after(:all) do
    Object.send(:remove_const, :Validatable)
  end

  it_behaves_like "an enumerable validator" do
    let(:options) { { attributes: [:field], in: ["foo", "bar", "baz"] } }
    let(:record) { Validatable.new }
  end

  describe "class and helper methods" do
    subject { Validatable.new }

    before { Validatable.clear_validators! }

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

    describe "validates" do
      before { Validatable.validates :field, inclusion: { in: ["foo", "bar", "baz"] } }
      it_behaves_like "it validates the inclusion of each member of the attribute value"
    end

  end

end
