require 'spec_helper'

describe Hydra::Validations::PresenceValidator do
  let(:validatable) do
    Class.new do
      def self.name
        'Validatable'
      end
      include ActiveModel::Validations
      include Hydra::Validations
      attr_accessor :an_attribute
      validates_presence_of :an_attribute, message: "Can't have blank values"
    end
  end

  context 'validation scenarios' do
    subject { validatable.new }
    [
      { values: [], valid?: false } ,
      { values: [''], valid?: false } ,
      { values: nil, valid?: false },
      { values: '', valid?: false },
      { values: ['work', ''], valid?: false },
      { values: ['work', nil], valid?: false },
      { values: ['work'], valid?: true },
      { values: 'work', valid?: true }
    ].each do |scenario|
      it "will validate #{scenario.fetch(:values).inspect} as valid? == #{scenario.fetch(:valid?)}" do
        subject.an_attribute = scenario.fetch(:values)
        expect(subject.valid?).to eq(scenario.fetch(:valid?))
      end
    end

    it 'should add error message' do
      subject.an_attribute = nil
      subject.valid?
      expect(subject.errors[:an_attribute]).to eq(["Can't have blank values"])
    end
  end
end
