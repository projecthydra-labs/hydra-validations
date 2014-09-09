require 'spec_helper'

describe Hydra::Validations::HelperMethods do

  before(:all) do
    class Validatable
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :field
    end
  end

  before(:each) { Validatable.clear_validators! }

  after(:all) { Object.send(:remove_const, :Validatable) }

  subject { Validatable.validators.first }

  describe ".validates_cardinality_of" do
    before { Validatable.validates_cardinality_of :field, is: 1 }
    it "should add a cardinality validator" do
      expect(subject).to be_a Hydra::Validations::CardinalityValidator
      expect(subject.options).to include({ is: 1 })
    end
  end

  describe ".validates_single_cardinality_of" do
    before { Validatable.validates_single_cardinality_of :field }
    it "should add a cardinality validator having :is=>1" do
      expect(subject).to be_a Hydra::Validations::CardinalityValidator
      expect(subject.attributes).to eq [:field]
      expect(subject.options).to include({ is: 1 })
    end
  end

  describe ".validates_format_of" do
    before { Validatable.validates_format_of :field, with: /\A[[:alpha:]]+\Z/ }
    it "should add a format validator" do
      expect(subject).to be_a Hydra::Validations::FormatValidator
      expect(subject.attributes).to eq [:field]
      expect(subject.options).to include({ with: /\A[[:alpha:]]+\Z/ })
    end
  end

  describe ".validates_inclusion_of" do
    before { Validatable.validates_inclusion_of :field, in: ["foo", "bar", "baz"] }
    it "should add an inclusion validator" do
      expect(subject).to be_a Hydra::Validations::InclusionValidator
      expect(subject.attributes).to eq [:field]
      expect(subject.options).to include({ in: ["foo", "bar", "baz"] })
    end
  end

  describe ".validates_uniqueness_of" do
    before { Validatable.validates_uniqueness_of :title, solr_name: "title_ssi" }
    it "should add a uniqueness validator" do
      expect(subject).to be_a Hydra::Validations::UniquenessValidator
      expect(subject.attributes).to eq [:title]
      expect(subject.options).to include({ solr_name: "title_ssi" })
    end
  end

end
