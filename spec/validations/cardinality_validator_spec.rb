require 'spec_helper'

describe Hydra::Validations::CardinalityValidator do

  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end

  before(:each) do
    Validatable.clear_validators!
    Validatable.validates :field, options 
    allow(record).to receive(:field) { value }
  end

  after(:all) { Object.send(:remove_const, :Validatable) }

  let(:record) { Validatable.new }

  let(:opts) { { cardinality: cardinality } }

  shared_examples "it has cardinality 0" do
    let(:options) { opts }
    describe "and :is == 0" do
      let(:cardinality) { { is: 0 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :is > 0" do
      let(:cardinality) { { is: 1 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :minimum == 0" do
      let(:cardinality) { { minimum: 0 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :minimum > 0" do
      let(:cardinality) { { minimum: 1 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
  end

  shared_examples "it has cardinality 1" do
    let(:options) { opts }
    describe "and is == 0" do
      let(:cardinality) { { is: 0 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :is == 1" do
      let(:cardinality) { { is: 1 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :is > 1" do
      let(:cardinality) { { is: 2 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :minimum == 0" do
      let(:cardinality) { { minimum: 0 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :minimum == 1" do
      let(:cardinality) { { minimum: 1 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :minimum > 1" do
      let(:cardinality) { { minimum: 2 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :maximum == 0" do
      let(:cardinality) { { maximum: 0 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :maximum == 1" do
      let(:cardinality) { { maximum: 1 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :maximum > 1" do
      let(:cardinality) { { maximum: 2 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
  end

  describe "when value is nil" do
    let(:value) { nil }
    it_behaves_like "it has cardinality 0"
  end

  describe "when value is an empty string" do
    let(:value) { "" }
    it_behaves_like "it has cardinality 1"
  end

  describe "when value is a non-empty string" do
    let(:value) { "foo" }
    it_behaves_like "it has cardinality 1"
  end

  describe "when value is an empty enumerable" do
    let(:value) { [] }
    it_behaves_like "it has cardinality 0"
    describe "and `allow_empty: true`" do
      let(:options) { opts.merge(allow_empty: true) }
      describe "and :is != 0" do
        let(:cardinality) { { is: 1 } }
        it "should be valid" do
          expect(record).to be_valid
        end
      end
      describe "and :minimum > 0" do
        let(:cardinality) { { minimum: 1 } }
        it "should be valid" do
          expect(record).to be_valid
        end
      end
    end
  end

  describe "when value is a non-empty enumerable" do
    let(:value) { ["foo", "bar"] }
    let(:options) { opts }
    describe "and :is != length" do
      let(:cardinality) { { is: 1 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :is == length" do
      let(:cardinality) { { is: 2 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :minimum < length" do
      let(:cardinality) { { minimum: 1 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :minimum == length" do
      let(:cardinality) { { minimum: 2 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :minimum > length" do
      let(:cardinality) { { minimum: 3 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :maximum < length" do
      let(:cardinality) { { maximum: 1 } }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
    describe "and :maximum == length" do
      let(:cardinality) { { maximum: 2 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    describe "and :maximum > length" do
      let(:cardinality) { { maximum: 3 } }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
  end

end
