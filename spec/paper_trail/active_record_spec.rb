RSpec.describe PaperTrail::ActiveRecordExt do
  it "has a version number" do
    expect(PaperTrail::ActiveRecordExt.version).to be_present
  end
end
