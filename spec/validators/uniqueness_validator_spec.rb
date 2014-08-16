require 'spec_helper'
require 'active_fedora'

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
      has_attributes :creator, datastream: 'descMetadata', multiple: false
      has_attributes :subject, datastream: 'descMetadata', multiple: true
    end
  end

  after(:all) { Object.send(:remove_const, :Validatable) }

  describe "exceptions" do
    before { Validatable.clear_validators! }
    it "cannot be used on a multi-valued attribute" do
      expect { Validatable.validates :subject, uniqueness: { solr_name: "subject_ssim" } }.to raise_error
    end
    it "cannot be used on more than one attribute at a time" do
      expect { Validatable.validates :title, :creator, uniqueness: { solr_name: "snafu_ssim" } }.to raise_error
    end
    it "cannot be used without the :solr_name option" do
      expect { Validatable.validates :title, uniqueness: true }.to raise_error
    end
  end

  describe "validation" do
    subject { Validatable.new(pid: "foobar:1", title: "I am Unique!") }
    let(:solr_name) { "title_ssi" }
    before do
      Validatable.clear_validators!
      Validatable.validates_uniqueness_of :title, solr_name: solr_name
    end
    context "when the record is new" do
      before { allow(subject).to receive(:persisted?) { false } }
      it_behaves_like "it validates the uniqueness of the attribute value" do
        let(:conditions) { {solr_name => subject.title} }
      end
    end
    context "when the record is persisted" do
      before { allow(subject).to receive(:persisted?) { true } }
      it_behaves_like "it validates the uniqueness of the attribute value" do
        let(:conditions) { {solr_name => subject.title, "-id" => subject.pid} }
      end
    end
  end
end
