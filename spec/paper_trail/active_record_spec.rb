RSpec.describe PaperTrail::ActiveRecord do
  it "has a version number" do
    expect(PaperTrail::ActiveRecord.version).to be_present
  end
end
