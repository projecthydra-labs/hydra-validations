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
