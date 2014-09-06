shared_examples "it validates the single cardinality of an enumerable attribute" do
  it "should be valid when the attribute value is nil" do
    subject.send("#{attribute}=", nil)
    expect(subject).to be_valid
  end
  it "should be valid if the value is empty" do
    subject.send("#{attribute}=", [])
    expect(subject).to be_valid
  end
  it "should be valid if the value has one element" do
    subject.send("#{attribute}=", ["foo"])
    expect(subject).to be_valid
  end
  it "should be invalid if the value has more than one element" do
    subject.send("#{attribute}=", ["foo", "bar"])
    expect(subject).not_to be_valid      
  end
end

shared_examples "it validates the single cardinality of a scalar attribute" do
  it "should be valid when the attribute value is nil" do
    subject.send("#{attribute}=", nil)
    expect(subject).to be_valid
  end
  it "should be valid when the value is blank" do
    subject.send("#{attribute}=", "")
    expect(subject).to be_valid
  end
  it "should be valid when the value is present" do
    subject.send("#{attribute}=", "foo")
    expect(subject).to be_valid
  end
end

shared_examples "an enumerable validator" do

  let(:record) { record_class.new }

  before do
    record_class.validates attribute, opts
    allow(record).to receive(attribute) { value }
  end

  context "when the value is nil" do
    let(:value) { nil }
    context "and `allow_nil` is true" do
      let(:opts) { options.merge(allow_nil: true) }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    context "and `allow_nil` is not true" do
      let(:opts) { options }
      it "should validate the value" do
        expect_any_instance_of(described_class).to receive(:validate_each).with(record, attribute, value)
        record.valid?
      end
    end
  end

  context "when the value is a blank scalar" do
    let(:value) { "" }
    context "and `allow_blank` is true" do
      let(:opts) { options.merge(allow_blank: true) }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    context "and `allow_blank` is not true" do
      let(:opts) { options }
      it "should validate the value" do
        expect_any_instance_of(described_class).to receive(:validate_each).with(record, attribute, value)
        record.valid?
      end
    end
  end

  context "when the value is is a non-blank scalar" do
    let(:value) { "foo" }
    let(:opts) { options }
    it "should validate the value" do
      expect_any_instance_of(described_class).to receive(:validate_each).with(record, attribute, value)
      record.valid?
    end
  end

  context "when the value is an empty enumerable" do
    let(:value) { [] }
    context "and `allow_blank` is true" do
      let(:opts) { options.merge(allow_blank: true) }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    context "and `allow_empty` is true" do
      let(:opts) { options.merge(allow_empty: true) }
      it "should be valid" do
        expect(record).to be_valid
      end
    end
    context "and neither `allow_blank` nor `allow_empty` is true" do
      let(:opts) { options }
      it "should be invalid" do
        expect(record).to be_invalid
      end
    end
  end

end
