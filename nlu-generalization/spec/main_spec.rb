require "main"

RSpec.describe NLStudent do
  subject { described_class.new }

  context "fundamental blocks" do
    describe "currency" do
      it "learns about $10" do

      end
    end
  end

  context "connecting blocks" do
    it "learns a phrase structure" do
      #ap subject.teach("10 in restaurant", fn: :create_entry)
      ap subject.teach("$10 in restaurant", fn: :create_entry)
      # $[type:dollar] [type:position] [type:category]

      ap subject.teach("10 in restaurant", fn: :create_entry)
      # $[type:number] [type:position] [type:category]
      #subject.teach("$10 in restaurant", fn: :create_entry)
    end
  end
end
