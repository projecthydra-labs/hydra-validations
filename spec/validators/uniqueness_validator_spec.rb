require 'spec_helper'
require 'active_fedora'
require 'support/shared_examples_for_validators'

shared_examples "it validates the uniqueness of the attribute value" do
  context "when the value is not taken" do
    before { allow(Validatable).to receive(:exists?).with(conditions) { false } }
    it "should be valid" do
      expect(subject).to be_valid
    end
  end
  context "when the value is taken" do
    before { allow(Validatable).to receive(:exists?).with(conditions) { true } }
    it "should not be valid" do
      expect(subject).not_to be_valid
    end
  end
end

describe Hydra::Validations::UniquenessValidator do

  before(:all) do
    class Validatable < ActiveFedora::Base
      include Hydra::Validations
      has_metadata name: 'descMetadata', type: ActiveFedora::QualifiedDublinCoreDatastream
      has_attributes :title, datastream: 'descMetadata', multiple: false
      has_attributes :source, datastream: 'descMetadata', multiple: true
    end
  end

  after(:all) { Object.send(:remove_const, :Validatable) }

  describe "exceptions" do
    before { Validatable.clear_validators! }
    it "cannot be used on more than one attribute at a time" do
      expect { Validatable.validates :title, :source, uniqueness: { solr_name: "snafu_ssim" } }.to raise_error
    end
    it "cannot be used without the :solr_name option" do
      expect { Validatable.validates :title, uniqueness: true }.to raise_error
    end
  end

  describe "validation" do
    subject { Validatable.new(pid: "foobar:1", title: "I am Unique!", source: ["Outer Space"]) }
    context "with a scalar attribute (:multiple=>false)" do
      before(:all) do
        Validatable.clear_validators!
        Validatable.validates_uniqueness_of :title, solr_name: "title_ssi"
      end
      it_behaves_like "it validates the single cardinality of a scalar attribute" do
        let(:attribute) { :title }
      end
      context "when the record is new" do
        before { allow(subject).to receive(:persisted?) { false } }
        it_behaves_like "it validates the uniqueness of the attribute value" do
          let(:conditions) { {"title_ssi" => subject.title} }
        end
      end
      context "when the record is persisted" do
        before { allow(subject).to receive(:persisted?) { true } }
        it_behaves_like "it validates the uniqueness of the attribute value" do
          let(:conditions) { {"title_ssi" => subject.title, "-id" => subject.pid} }
        end
      end
    end
    context "with an enumerable attribute (:multiple=>true)" do
      before(:all) do
        Validatable.clear_validators!
        Validatable.validates_uniqueness_of :source, solr_name: "source_ssim"
      end
      it_behaves_like "it validates the single cardinality of an enumerable attribute" do
        let(:attribute) { :source }
      end
      context "when the record is new" do
        before { allow(subject).to receive(:persisted?) { false } }
        it_behaves_like "it validates the uniqueness of the attribute value" do
          let(:conditions) { {"source_ssim" => subject.source.first} }
        end
      end
      context "when the record is persisted" do
        before { allow(subject).to receive(:persisted?) { true } }
        it_behaves_like "it validates the uniqueness of the attribute value" do
          let(:conditions) { {"source_ssim" => subject.source.first, "-id" => subject.pid} }
        end
      end      
    end
  end
end
