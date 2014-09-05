
shared_examples "an enumerable validator" do

  subject { described_class.new(options) }

  before(:each) { allow(record).to receive(:field) { value }  }

  describe "when the value is nil" do
    let(:value) { nil }
    context "and the `allow_nil` option is used" do
      before { options.merge!(allow_nil: true) }
      it "should not validate the value" do
        expect(subject).not_to receive(:validate_each)
        subject.validate(record)
      end
    end
    context "and the `allow_nil` option is not used" do
      it "should validate the value" do
        expect(subject).to receive(:validate_each).with(record, :field, value)
        subject.validate(record)
      end
    end
  end

  describe "when the value is a blank scalar" do
    let(:value) { "" }
    context "and the `allow_blank` option is used" do
      before { options.merge!(allow_blank: true) }
      it "should not validate the value" do
        expect(subject).not_to receive(:validate_each)
        subject.validate(record)
      end
    end
    context "and the `allow_blank` option is not used" do
      it "should validate the value" do
        expect(subject).to receive(:validate_each).with(record, :field, value)
        subject.validate(record)
      end
    end    
  end

  describe "when the value is a non-blank scalar" do
    let(:value) { "foo" }
    it "should validate the value" do
      expect(subject).to receive(:validate_each).with(record, :field, value)
      subject.validate(record)
    end
  end

  describe "when the value is an empty array" do
    let(:value) { [] }
    context "and the `allow_blank` option is used" do
      before { options.merge!(allow_blank: true) }
      it "should not validate the value" do
        expect(subject).not_to receive(:validate_each)
        subject.validate(record)
      end
    end
    context "and the `allow_empty` option is used" do
      before { options.merge!(allow_empty: true) }
      it "should be valid" do
        subject.validate(record)
        expect(record.errors).to be_empty
      end
    end    
    context "and neither `allow_blank` nor `allow_empty` is used" do
      it "should be invalid" do
        subject.validate(record)
        expect(record.errors[:field]).to eq ["can't be empty"]
      end
    end    
  end

  describe "when the value is a non-empty enumerable" do
    let(:value) { ["foo", "bar"] }
    it "should validate each member of the value" do
      pending
      #expect(subject).to receive(:validate_each).with(record, :field, value).and_call_original
      value.each { |v| expect(subject).to receive(:validate_each).with(record, :field, v).and_call_original }
      subject.validate(record)
    end
    it "should 'fix' the error messages"
  end

end
