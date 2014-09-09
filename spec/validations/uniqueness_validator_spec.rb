require 'spec_helper'
require 'support/shared_examples_for_validators'

describe Hydra::Validations::UniquenessValidator do

  before(:all) do
    class Validatable
      def self.exists?(*args)
      end
      def self.name
        'Validatable'
      end
      def persisted?
      end
      def initialize(attributes = {})
        attributes.each do |k,v|
          send("#{k}=", v)
        end
      end
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :pid, :title, :source
      alias_method :id, :pid
    end
  end

  after(:all) { Object.send(:remove_const, :Validatable) }

  before(:each) { Validatable.clear_validators! }

  describe "exceptions" do
    it "cannot be used on more than one attribute at a time" do
      expect { Validatable.validates :title, :source, uniqueness: { solr_name: "snafu_ssim" } }.to raise_error
    end
    it "cannot be used without the :solr_name option" do
      expect { Validatable.validates :title, uniqueness: true }.to raise_error
    end
  end

  describe "validation" do

    subject { Validatable.new(pid: "foobar:1", title: "I am Unique!", source: ["Outer Space"]) }

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

    context "with a scalar attribute (:multiple=>false)" do
      before { Validatable.validates :title, uniqueness: { solr_name: "title_ssi" } }
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
      before { Validatable.validates :source, uniqueness: { solr_name: "source_ssim" } }
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
